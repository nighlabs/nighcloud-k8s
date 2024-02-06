# Overview
This is my single node version of a k8s cluster.  I'm using this as a method to refine my skills to work into a larger cluster with HA.  The cluster is deployed on a Proxmox hypervisor.

The goal is to create a cluster which uses Talos Linux, Cilium CNI, Github for storage of configuration, Flux CD for deployment, Rook/Ceph for shared storage, an Ingress (Cilium, Traefik, Envoy, or Nginx), Cert Manager for certificates, and Vault for secret storage.

The overall step of what I'm envisioning will take the following steps to create:
- ✅ Basic deployment
- ✅ 2 NIC Cards
- ✅ Github storage for configuration
- ✅ Install Cilium
- ✅ Flux CD
- ✅ Flux CD -> Backport Cilium
- ✅ Flux CD -> HCP Vault Secrets w/ vault-secrets-operator
- ✅ Flux CD -> Cilium as L2 Load Balancer
- ✅ Flux CD -> Ingress (Envoy)
- ☑️ Flux CD -> Rook Ceph w/ External Ceph
- ✅ Flux CD -> Cert Manager
- ☑️ Flux CD -> Vault
- ☑️ Flux CD -> Cloudflare Tunnels

## Secrets discussion
Overall, there's several styles of secrets for FluxCD: SOPS, Sealed Secrets.  Both SOPS and Sealed Secrets allow you to take files with secrets in them and encrypt/decrypt the sensitive data.  The cypher text is then stored inside of the files before checking them into GitHub.

I liked the options of those but was still uncomfortable storing secrets encrypted in GitHub.  But why?  I have no worries about encrypted secrets for services that would not be accessible from the internet.  These would have a second step to use a cracked secret.  My concern comes for the encrypted secrets which are used for cloud services (Cloudflare API, etc).

As a result, I continued searching.  I love Hashicorp Vault as it allows for secure storage of secrets.  However, for the cluster, I end up with a 🐓/🥚 problem in that I can't use Vault if I haven't create the Vault.  Enter Hashicorp Vault Secrets!  It's a cloud platform which offers a key/value store for secrets.  When paired with their secrets operator, the secrets can be synchronized to secrets in k8s.  This allows for secrets separated from the GitHub repo.  The drawback of this philosophy is that there's small parts of the k8s manifests; however, I believe this is a good trade-off to security of the secrets.

## Create the host machines and bootstrap K8s
- Create a talos configuration for the cluster: `talosctl gen config kubedoo-lonelynode https://172.16.1.40:6443`
- Create a talos machine configuration: `talosctl machineconfig patch controlplane.yaml --patch @patch-kubedoo-1.yaml -o ./_talos/_out/kubedoo-1.yaml`
- Boot the machine - set it's IP to 172.16.1.41
- Apply the machine configuration: `talosctl apply-config --insecure -n 172.16.1.41 --file ./_talos/_out/kubedoo-1.yaml`
- Bootstrap one of the control plane nodes: `talosctl bootstrap --nodes 172.16.1.41 --endpoints 172.16.1.41 --talosconfig=./talosconfig`
- Grab the kubeconfig: `talosctl kubeconfig --nodes 172.16.1.40 --endpoints 172.16.1.40 --talosconfig ./talosconfig`
- Install Cilium CNI
```
    helm repo add cilium https://helm.cilium.io/
    helm install cilium cilium/cilium \
        --version 1.14.5 \
        --namespace kube-system \
        -f ./_talos/cilium-values.yaml
```
- Test cilium: `cilium status`
- Test nodes: `kubectl --kubeconfig=./kubeconfig get nodes`

## Add a deployment key to the github repo
Flux will need access to the github repo.  The goal will be to use SSH and a deployment key on the repo.  This will allow Flux to access it.  I anticipate using the image updating so it'll need write access.
- Generate the SSH Key: `ssh-keygen -t ed25519 -C "nighcloud - kubedoo-lonelynode"`
- Add it as a deployment key in Github on the Repository.  For my purposes, I set it with write access.

## Deploy FluxCD to the Cluster
Now install and bootstrap Flux.
- Bootstrap flux - take care, everything in clusters/kubedoo-lonely node is injested by Flux:
    ```
    flux bootstrap git \
        --url=ssh://git@github.com/nighlabs/nighcloud-k8s \
        --branch=main \
        --private-key-file=/Users/chris/.ssh/kubedoo-lonelynode \
        --password=REPLACEME \
        --path=clusters/kubedoo-lonelynode
    ```

## Configure initial secrets for vault-secrets-operator
We'll need to provide an initial secret for the vault secrets operator to be able to authenticate to Vault Secrets in HCP Cloud.

First create a service principal in HCP Vault Secrets and setup env for them (NOTE: turn off shell history... fp -c in macos)
```
export HCP_CLIENT_ID=
export HCP_CLIENT_SECRET=
```

Create the cert-manager secret bootstrap
```
kubectl create -f - <<EOF
apiVersion: secrets.hashicorp.com/v1beta1
kind: HCPVaultSecretsApp
metadata:
  name: hcp-cert-manager-bootstrap-authsp
  namespace: cert-manager
spec:
  appName: cert-manager-bootstrap
  destination:
    create: true
    labels:
      hvs: "true"
    name: hcp-cert-manager-bootstrap-authsp
  refreshAfter: 24h
EOF
```