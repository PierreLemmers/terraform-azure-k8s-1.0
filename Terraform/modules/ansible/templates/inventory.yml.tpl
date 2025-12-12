all:
  hosts:
%{ for vm in hosts ~}
    ${vm.name}:
      ansible_host: ${vm.ip}
%{ endfor ~}

  children:
    control:
      hosts:
%{ for control in hosts ~}
%{ if control.role == 'k8s-control' }
        ${control.name}: {}
%{ endfor ~}
    workers:
      hosts:
%{ for worker in hosts ~}
%{ if worker.role == 'k8s-worker' }
        ${worker.name}: {}
%{ endfor ~}
    harbor:
      hosts:
        harbor-server-1:
          ansible_host: ${harbor.ip}
