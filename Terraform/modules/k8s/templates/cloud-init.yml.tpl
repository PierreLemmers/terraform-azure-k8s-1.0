#cloud-config

hostname: ${hostname}
manage_etc_hosts: true

users:
  - name: ansible
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}

package_update: true
package_upgrade: true

%{ if role == "ansible" }
write_files:
  - path: /home/ansible/.ssh/id_rsa
    owner: ansible:ansible
    permissions: "0600"
    content: |
${indent(6, ssh_private_key)}

  - path: /home/ansible/.ssh/id_rsa.pub
    owner: ansible:ansible
    permissions: "0644"
    content: |
${indent(6, ssh_public_key)}

runcmd:
  - mkdir -p /home/ansible/.ssh
  - chown -R ansible:ansible /home/ansible/.ssh
  - echo "Ansible control node ready" > /etc/motd
%{ endif }

%{ if role == "k8s-control" || role == "k8s-worker" }
runcmd:
  - swapoff -a
  - sed -i '/ swap / s/^/#/' /etc/fstab
  - echo "Kubernetes node ready" > /etc/motd
%{ endif }

%{ if role == "harbor" }
packages:
  - docker.io
  - docker-compose

runcmd:
  - systemctl enable docker
  - systemctl start docker
  - echo "Harbor node ready" > /etc/motd
%{ endif }
