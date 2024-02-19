terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.4.0"
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
