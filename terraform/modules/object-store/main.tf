terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

provider "linode" {
  token      = var.linode_token
}

resource "linode_object_storage_bucket" "mimir-bucket" {
  label      = "mimir-bucket"
  region     = var.region
  acl        = "public-read"
}

resource "linode_object_storage_bucket" "loki-bucket" {
  label      = "loki-bucket"
  region     = var.region
  acl        = "public-read"
}