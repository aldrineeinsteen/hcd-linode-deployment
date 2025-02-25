terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace" "hcd-cluster" {
  metadata {
    name = var.project_name

    labels = {
        "mission-control.datastax.com/is-project" = "true"
    }

    annotations = {
      "mission-control.datastax.com/project-name" = var.project_name
    }
  }
}

resource "local_file" "mission_control_yaml" {
  filename = "${path.module}/mission_control.yaml"
  content  = templatefile("${path.module}/hcd_template.yaml", {
    project_name = var.project_name
    cluster_name = var.cluster_name
    datacenters  = var.datacenters
  })
}

resource "null_resource" "apply_mission_control" {
  depends_on = [local_file.mission_control_yaml]

  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG="${var.kube_config_path}"
    echo "⏳ Applying dynamically generated Mission Control YAML..."
    kubectl apply -f ${path.module}/mission_control.yaml
    EOT
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}