#cloud-config
hostname: ${hostname}
manage_etc_hosts: true

%{ if role == "ansible" && create_ansible_user }
bootcmd:
  - [ bash, -lc, "id ansible >/dev/null 2>&1 || useradd -m -s /bin/bash ansible" ]
  - [ bash, -lc, "usermod -aG sudo ansible || true" ]
  - [ bash, -lc, "mkdir -p /home/ansible/.ssh /home/ansible/ansible/inventory /home/ansible/projects" ]
  - [ bash, -lc, "chown -R ansible:ansible /home/ansible" ]
%{ endif }

users:
  - name: ${admin_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}

package_update: true
packages:
%{ for p in extra_packages ~}
  - ${p}
%{ endfor ~}
%{ if install_ansible }
  - git
  - python3
  - python3-pip
  - ansible
%{ endif }


write_files:
%{ if role == "ansible" && inventory_yaml != "" }
  - path: /home/ansible/ansible/inventory/inventory.yml
    owner: ansible:ansible
    permissions: "0644"
    content: ${jsonencode(inventory_yaml)}
%{ endif }
%{ if role == "ansible" && ssh_private_key_b64 != "" }
  - path: /home/ansible/.ssh/lab_key
    owner: ansible:ansible
    permissions: "0600"
    encoding: b64
    content: |
      ${ssh_private_key_b64}
%{ endif }

runcmd:
%{ if role == "ansible" }
  - [ bash, -lc, "install -d -o ansible -g ansible /home/ansible/ansible/inventory /home/ansible/.ssh ${git_dest_dir}" ]
  - [ bash, -lc, "chown -R ansible:ansible /home/ansible/ansible /home/ansible/.ssh ${git_dest_dir}" ]
%{ if ssh_private_key_b64 != "" }
  - [ bash, -lc, "chmod 700 /home/ansible/.ssh && chmod 600 /home/ansible/.ssh/lab_key" ]
%{ endif }
%{ if git_repo_url != "" }
  - [ bash, -lc, "apt-get update -y" ]
  - [ bash, -lc, "apt-get install -y git ca-certificates" ]
  - [ bash, -lc, "set -e; DEST='${git_dest_dir}/terraform-azure-k8s-1.0'; if [ -d \"$DEST/.git\" ]; then sudo -u ansible bash -lc \"cd \\\"$DEST\\\" && git fetch --all && git checkout ${git_repo_branch} && git pull\"; else sudo -u ansible bash -lc \"git clone --branch ${git_repo_branch} ${git_repo_url} \\\"$DEST\\\"\"; fi" ]
%{ endif }
%{ endif }
