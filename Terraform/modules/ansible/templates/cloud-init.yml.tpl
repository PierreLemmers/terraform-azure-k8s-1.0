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
  - mkdir -p /home/ansible/projects/kubernetes/roles
  - chown -R ansible:ansible /home/ansible/projects/kubernetes
  - touch /home/ansible/projects/kubernetes/inventory
  - touch /home/ansible/projects/kubernetes/ansible.cfg
  - echo "Ansible control node initialized" > /etc/motd

write_files:
  - path: /home/ansible/projects/kubernetes/inventory
    content: ${inventory_content}
    owner: ansible:ansible
    permissions: "0644"
%{ endif }
