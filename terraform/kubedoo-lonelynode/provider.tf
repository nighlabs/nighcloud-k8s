terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.4.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

terraform {
  cloud {
    organization = "nighcloud"
    workspaces {
      name = "homelab-kubedoo-lonelynode"
    }
  }
}

provider "talos" {}

provider "helm" {}

provider "kubectl" {
  apply_retry_count = 30
  host                    = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
  cluster_ca_certificate  = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  client_certificate      = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
  client_key              = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
}