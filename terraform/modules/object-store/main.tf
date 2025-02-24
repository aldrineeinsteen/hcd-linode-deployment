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
  label  = "mimir-bucket"
  region = var.region
  acl    = "public-read"

  lifecycle {
    prevent_destroy = false
  }
}

resource "linode_object_storage_bucket" "loki-bucket" {
  label  = "loki-bucket"
  region = var.region
  acl    = "public-read"

  lifecycle {
    prevent_destroy = false
  }
}

output "mimir-bucket-id" {
  value = "Mimir's bucket id is ${linode_object_storage_bucket.mimir-bucket.id}"
}

output "loki-bucket-id" {
  value = linode_object_storage_bucket.loki-bucket.id
}