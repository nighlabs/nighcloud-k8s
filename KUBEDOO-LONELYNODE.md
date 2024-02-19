# Overview
This is my single node version of a k8s cluster.  I'm using this as a method to refine my skills to work into a larger cluster with HA.  The cluster is deployed on a Proxmox hypervisor.

The goal is to create a cluster which uses Talos Linux, Cilium CNI, Github for storage of configuration, Argo CD for deployment, Rook/Ceph for shared storage, an Ingress (Cilium, Traefik, Envoy, or Nginx), Cert Manager for certificates, and Vault for secret storage.

The initial Talo cluster installation is handled by Terraform replicatable deployments.

The overall step of what I'm envisioning will take the following steps to create:
- ✅ Basic deployment
- ✅ 2 NIC Cards
- ✅ Github storage for configuration
- ☑️ Install Cilium
- ☑️ Argo CD
- ☑️ Argo CD -> Backport Cilium
- ☑️ Argo CD -> HCP Vault Secrets w/ vault-secrets-operator
- ☑️ Argo CD -> Cilium as L2 Load Balancer
- ☑️ Argo CD -> Ingress (Envoy)
- ☑️ Argo CD -> Rook Ceph w/ External Ceph
- ☑️ Argo CD -> Cert Manager
- ☑️ Argo CD -> Vault
- ☑️ Argo CD -> Cloudflare Tunnels

## Create the host machines and bootstrap K8s
- Boot the machine - set it's IP to 172.16.1.41
- Log into Terraform Cloud: `terraform login`
- Apply the terraform configuration in terraform/kubedoo-lonelynode: `terraform apply`

# Old/Obsolete Sections
With FluxCD's company Weaveworks dissolving, I'm rearchitecting with ArgoCD.  As part of that effort, I've taken to using Terraform for the initial cluster configuration and ArgoCD installation.

This has made a lot of the discussions to be a bit obsolete.

## Secrets discussion
Overall, there's several styles of secrets for FluxCD: SOPS, Sealed Secrets.  Both SOPS and Sealed Secrets allow you to take files with secrets in them and encrypt/decrypt the sensitive data.  The cypher text is then stored inside of the files before checking them into GitHub.

I liked the options of those but was still uncomfortable storing secrets encrypted in GitHub.  But why?  I have no worries about encrypted secrets for services that would not be accessible from the internet.  These would have a second step to use a cracked secret.  My concern comes for the encrypted secrets which are used for cloud services (Cloudflare API, etc).

As a result, I continued searching.  I love Hashicorp Vault as it allows for secure storage of secrets.  However, for the cluster, I end up with a 🐓/🥚 problem in that I can't use Vault if I haven't create the Vault.  Enter Hashicorp Vault Secrets!  It's a cloud platform which offers a key/value store for secrets.  When paired with their secrets operator, the secrets can be synchronized to secrets in k8s.  This allows for secrets separated from the GitHub repo.  The drawback of this philosophy is that there's small parts of the k8s manifests; however, I believe this is a good trade-off to security of the secrets.


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

First create a service principal in HCP Vault Secrets and setup env for them (NOTE: turn off shell history... `fc -p` in macos).  Then create the k8s secret
```
export HCP_CLIENT_ID=
export HCP_CLIENT_SECRET=

kubectl create secret generic hcp-vso-serviceprincipal \
    --namespace cert-manager \
    --from-literal=clientID=$HCP_CLIENT_ID \
    --from-literal=clientSecret=$HCP_CLIENT_SECRET
```