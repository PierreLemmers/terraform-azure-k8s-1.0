all:
  children:
    ansible:
      hosts:
        ansible:
          ansible_host: ${hosts["ansible"].ip}

    # --- LAN K8s cluster groups ---
    k8s_lan_control:
      hosts:
%{ for k, v in hosts ~}
%{ if v.role == "k8s-control" && v.cluster == "lan" }
        ${v.name}:
          ansible_host: ${v.ip}
%{ endif ~}
%{ endfor ~}

    k8s_lan_workers:
      hosts:
%{ for k, v in hosts ~}
%{ if v.role == "k8s-worker" && v.cluster == "lan" }
        ${v.name}:
          ansible_host: ${v.ip}
%{ endif ~}
%{ endfor ~}

    k8s_lan:
      children:
        k8s_lan_control: {}
        k8s_lan_workers: {}

    # --- Runner K8s cluster groups ---
    k8s_runner_control:
      hosts:
%{ for k, v in hosts ~}
%{ if v.role == "k8s-control" && v.cluster == "runner" }
        ${v.name}:
          ansible_host: ${v.ip}
%{ endif ~}
%{ endfor ~}

    k8s_runner_workers:
      hosts:
%{ for k, v in hosts ~}
%{ if v.role == "k8s-worker" && v.cluster == "runner" }
        ${v.name}:
          ansible_host: ${v.ip}
%{ endif ~}
%{ endfor ~}

    k8s_runner:
      children:
        k8s_runner_control: {}
        k8s_runner_workers: {}

    # --- Combined Kubernetes parent group (both clusters) ---
    kubernetes:
      children:
        k8s_lan: {}
        k8s_runner: {}

    # --- GitLab (LAN) ---
    gitlab:
      hosts:
%{ for k, v in hosts ~}
%{ if v.role == "gitlab" }
        ${v.name}:
          ansible_host: ${v.ip}
%{ endif ~}
%{ endfor ~}

    # --- Harbor groups (split) ---
    harbor_lan:
      hosts:
%{ for k, v in hosts ~}
%{ if v.role == "harbor-lan" }
        ${v.name}:
          ansible_host: ${v.ip}
%{ endif ~}
%{ endfor ~}

    harbor_dmz:
      hosts:
%{ for k, v in hosts ~}
%{ if v.role == "harbor-dmz" }
        ${v.name}:
          ansible_host: ${v.ip}
%{ endif ~}
%{ endfor ~}

    harbor:
      children:
        harbor_lan: {}
        harbor_dmz: {}
