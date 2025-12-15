users:
  - name: ansible
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_key}

%{ if role == "ansible"}
package_update: true
packages:
  - git
  - python3
  - python3-pip
  - ansible

runcmd:
  - mkdir -p /home/ansible/projects
  - chown -R ansible:ansible /home/ansible/projects
  - echo "Ansible control node initialized" > /etc/motd
%{ endif }

%{ if role == "k8s-control" || role == "k8s-worker" }
packages:
  - ca-certificates
  - curl
  - gnupg
  - lsb-release

runcmd:
  - swapoff -a
  - sed -i '/ swap / s/^/#/' /etc/fstab
  - modprobe overlay
  - modprobe br_netfilter
  - sysctl --system
  - echo "Kubernetes node prepared" > /etc/motd
%{ endif }

%{ if role == "harbor" }
packages:
  - docker.io
  - docker-compose

runcmd:
  - systemctl enable docker
  - systemctl start docker
  - echo "Harbor server initialized" > /etc/motd
%{ endif }
