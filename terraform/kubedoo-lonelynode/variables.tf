variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
}

variable "cluster_vip" {
  description = "The VIP used for the cluster"
  type        = string
}

variable "cluster_advertisedsubnets" {
  description = "The subnet used for etcd subnet advertisement"
  type        = string
}

variable "cluster_nameserver" {
  description = "The nameserver used for the cluster"
  type        = string
}

variable "stornet_mtu" {
  description = "The MTU used for the storage network"
  type        = number
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk  = string
      hostname      = string
      mainnet_iface = string
      mainnet_ip    = string
      stornet_iface = string
      stornet_ip    = string
    }))
  })
}
