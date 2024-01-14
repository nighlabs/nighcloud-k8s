# Overview
This is my single node version of a k8s cluster.  I'm using this as a method to refine my skills to work into a larger cluster with HA.  The cluster is deployed on a Proxmox hypervisor.

The goal is to create a cluster which uses Talos Linux, Cilium CNI, Github for storage of configuration, Flux CD for deployment, Rook/Ceph for shared storage, an Ingress (Cilium, Traefik, Envoy, or Nginx), Cert Manager for certificates, and Vault for secret storage.

The overall step of what I'm envisioning will take the following steps to create:
- ✅ Basic deployment
- ✅ 2 NIC Cards
- ✅ Github storage for configuration
- ☑️ Install Cilium
- ☑️ Flux CD
- ☑️ Flux CD -> Secured Secrets
- ☑️ Flux CD -> Ingress
- ☑️ Flux CD -> Rook Ceph w/ External Ceph
- ☑️ Flux CD -> Cert Manager
- ☑️ Flux CD -> Vault

## Commands used
- Create a talos configuration for the cluster: `talosctl gen config kubedoo-lonelynode https://172.16.1.40:6443`
- Create a talos machine configuration: `talosctl machineconfig patch controlplane.yaml --patch @patch-kubedoo-1.yaml -o ./_out/kubedoo-1.yaml`
- Boot the machine - set it's IP to 172.16.1.41
- Apply the machine configuration: `talosctl apply-config --insecure -n 172.16.1.41 --file ./_out/kubedoo-1.yaml`
- Bootstrap one of the control plane nodes: `talosctl bootstrap --nodes 172.16.1.41 --endpoints 172.16.1.41 --talosconfig=./talosconfig`
- Grab the kubeconfig: `talosctl kubeconfig --nodes 172.16.1.40 --endpoints 172.16.1.40 --talosconfig ./talosconfig .`
- Test nodes: `kubectl --kubeconfig=./kubeconfig get nodes`