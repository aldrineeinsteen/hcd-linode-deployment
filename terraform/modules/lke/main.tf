terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

resource "linode_lke_cluster" "hcd_cluster" {
  label   = "hcd-cluster"
  region  = var.region
  k8s_version = "1.32"
  tags    = ["HCD", "Linode", "Kubernetes"]

  pool {
    type  = "g6-standard-8"
    count = 3
  }
}


resource "local_file" "kubeconfig_file" {
  # filename = "${path.module}/kubeconfig"
  content  = base64decode(linode_lke_cluster.hcd_cluster.kubeconfig)
  filename = "${path.module}/kubeconfig"
}

output "kubeconfig" {
  value = abspath(local_file.kubeconfig_file.filename)
}