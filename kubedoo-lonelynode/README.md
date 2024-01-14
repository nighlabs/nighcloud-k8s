## Commands used
- Create a talos configuration for the cluster: `talosctl gen config kubedoo-lonelynode https://172.16.1.40:6443`
- Create a talos machine configuration: `talosctl machineconfig patch controlplane.yaml --patch @patch-kubedoo-1.yaml -o ./_out/kubedoo-1.yaml`
- Boot the machine - set it's IP to 172.16.1.41
- Apply the machine configuration: `talosctl apply-config --insecure -n 172.16.1.41 --file ./_out/kubedoo-1.yaml`
- Bootstrap one of the control plane nodes: `talosctl bootstrap --nodes 172.16.1.41 --endpoints 172.16.1.41 --talosconfig=./talosconfig`
- Grab the kubeconfig: `talosctl kubeconfig --nodes 172.16.1.40 --endpoints 172.16.1.40 --talosconfig ./talosconfig .`
- Test nodes: `kubectl --kubeconfig=./kubeconfig get nodes`