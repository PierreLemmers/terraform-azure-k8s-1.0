all:
  children:
    ansible:
      hosts:
        ansible:
          ansible_host: ${hosts["ansible"].ip}

    k8s_control:
      hosts:
%{ for k, v in hosts ~}
%{ if v.role == "k8s-control" }
        ${k}:
          ansible_host: ${v.ip}
%{ endif }
%{ endfor }

    k8s_workers:
      hosts:
%{ for k, v in hosts ~}
%{ if v.role == "k8s-worker" }
        ${k}:
          ansible_host: ${v.ip}
%{ endif }
%{ endfor }

    harbor:
      hosts:
        harbor:
          ansible_host: ${hosts["harbor"].ip}
