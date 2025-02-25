terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace" "hcd-cluster" {
  metadata {
    name = "hcd-cluster"

    labels = {
        "mission-control.datastax.com/is-project" = "true"
    }

    annotations = {
      "mission-control.datastax.com/project-name" = "hcd-cluster"
    }
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
  
}