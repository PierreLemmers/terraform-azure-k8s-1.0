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
