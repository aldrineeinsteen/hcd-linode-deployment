terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 2.34.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
  }
}

provider "linode" {
  token = var.linode_token
}