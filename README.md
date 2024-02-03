# Welcome
This repo has the talos configurations for the k8s configurations used for my homelab k8s clusters.  These are a work in-perpetual-progress as is for most homelabs.

## Layout
This repository has the talos configs, flux configuration/manifests, the commands I've used, and the research I've collected as I built the home lab.
- **./talos/kubedoo-lonelynode**: the talos configure for the single node talos k8s cluster.  See the [kubedoo-lonelynode cluster](KUBEDOO-LONELYNODE.md) instructions.
- **./clusters/kubedoo-lonelynode**: the flux configuration for the kubedoo-lonelynode single node k8s cluster

# References
Here's a list of the articles that I've recommended to mark as a source I'm consuming as reference.
- https://www.talos.dev/v1.6/talos-guides/configuration/patching/
- https://www.talos.dev/v1.6/talos-guides/howto/workers-on-controlplane/
- https://www.talos.dev/v1.6/kubernetes-guides/network/deploying-cilium/
- https://datavirke.dk/posts/bare-metal-kubernetes-part-2-cilium-and-firewalls/
- https://datavirke.dk/posts/bare-metal-kubernetes-part-1-talos-on-hetzner/
- https://developer.hashicorp.com/vault/tutorials/hcp-vault-secrets-get-started/kubernetes-vso