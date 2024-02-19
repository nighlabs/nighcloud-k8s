#Base Cluster Settings
cluster_name = "kubedoo-lonelynode"
cluster_endpoint = "https://172.16.1.40:6443"
cluster_vip = "172.16.1.40"
cluster_advertisedsubnets = "172.16.1.0/24"
cluster_nameserver = "172.16.1.254"
stornet_mtu = "8996"

#Node data for the cluster
node_data = {
    controlplanes = {
        "172.16.1.41" = {
            install_disk  = "/dev/sda"
            hostname      = "kubedoo-1"
            mainnet_iface = "enxbc241136f337"
            mainnet_ip    = "172.16.1.41/24"
            stornet_iface = "enxbc2411bfc8ec"
            stornet_ip    = "172.30.255.41/24"
        }
    }
}