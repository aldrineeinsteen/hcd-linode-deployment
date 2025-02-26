terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "null_resource" "wait_for_mission_control" {
  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG="${var.kube_config_path}"
    
    echo "⏳ Waiting for Mission Control to be available..."
    
    until kubectl get pods -n mission-control | grep -E "mission-control-ui|mission-control-aggregator" | grep "1/1"; do
      echo "Waiting for Mission Control pods to be running..."
      sleep 10
    done

    echo "✅ Mission Control is up and running."
    EOT
  }
}

resource "kubernetes_namespace" "hcd-cluster" {
  depends_on = [ null_resource.wait_for_mission_control ]
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
  depends_on = [ kubernetes_namespace.hcd-cluster ]
  filename = "${path.module}/mission_control.yaml"
  content  = templatefile("${path.module}/hcd_template.yaml", {
    project_name = var.project_name
    cluster_name = var.cluster_name
    datacenters  = var.datacenters
  })
}

resource "null_resource" "apply_mission_control" {
  depends_on = [local_file.mission_control_yaml, kubernetes_namespace.hcd-cluster]

  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG="${var.kube_config_path}"
    
    echo "⏳ Waiting for Mission Control CRDs to be ready..."
    
    # Wait until the CRD is available
    until kubectl get crd missioncontrolclusters.missioncontrol.datastax.com; do
      echo "Waiting for CRDs to be installed..."
      sleep 10
    done

    echo "✅ CRDs are installed. Applying dynamically generated Mission Control YAML..."
    kubectl apply -f ${path.module}/mission_control.yaml
    EOT
  }
}