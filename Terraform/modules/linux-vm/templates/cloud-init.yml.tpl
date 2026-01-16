#cloud-config
hostname: ${hostname}
manage_etc_hosts: true

users:
  - name: ${admin_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}

%{ if create_ansible_user }
  - name: ansible
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}
%{ endif }

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

runcmd:
  - echo "role=${role}" > /etc/carwash-role

%{ if role == "ansible" && ssh_private_key != "" }
write_files:
  - path: /home/ansible/.ssh/id_rsa
    owner: ansible:ansible
    permissions: "0600"
    content: |
${indent(6, ssh_private_key)}
%{ endif }

runcmd:
  - echo "role=${role}" > /etc/carwash-role

%{ if role == "ansible" && git_repo_url != "" }
  - apt-get update -y
  - apt-get install -y git ca-certificates
  - mkdir -p ${git_dest_dir}
  - chown -R ansible:ansible ${git_dest_dir}
  - |
      set -e
      DEST="${git_dest_dir}/carwash"
      if [ -d "$${DEST}/.git" ]; then
        sudo -u ansible bash -lc "cd $${DEST} && git fetch --all && git checkout ${git_repo_branch} && git pull"
      else
        sudo -u ansible bash -lc "git clone --branch ${git_repo_branch} ${git_repo_url} $${DEST}"
      fi
%{ endif }
