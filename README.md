# Welcome
This repo has the talos configurations for the k8s configurations used for my homelab k8s clusters.  These are a work in-perpetual-progress as is for most homelabs.

## Layout
Each of the folders represents a cluster.  The only files generally checked into git are the patch files.  The machine specific configurations and the talos configs have secrets mixed into them and should not be checked into git.

## Commands used
- Create a talos configuration for the cluster: `talosctl gen config <Cluster name> <Cluster K8s Endpoint>`
- Create a talos machine configuration: `talosctl machineconfig patch controlplane.yaml --patch @patch-file.yaml -o ./_out/machine-1.yaml`
- Apply the machine configuration: `talosctl apply-config --insecure -n <node ip> --file ./_out/machine-1.yaml`
- Set envs for handling which node/config we're using for ease:
    ```
    export TALOSCONFIG="./talosconfig"
    talosctl config endpoint 172.16.1.41
    talosctl config node 172.16.1.41
    ```
- Bootstrap one of the control plane nodes: `talosctl bootstrap`
- Grab the kubeconfig: `talosctl kubeconfig .`

# References
Here's a list of the articles that I've recommended to mark as a source I'm consuming as reference.
- https://www.talos.dev/v1.6/talos-guides/configuration/patching/
- https://www.talos.dev/v1.6/talos-guides/howto/workers-on-controlplane/
- https://www.talos.dev/v1.6/kubernetes-guides/network/deploying-cilium/
- https://datavirke.dk/posts/bare-metal-kubernetes-part-2-cilium-and-firewalls/
- https://datavirke.dk/posts/bare-metal-kubernetes-part-1-talos-on-hetzner/