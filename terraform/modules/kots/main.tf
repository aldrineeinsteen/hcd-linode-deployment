terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}
resource "kubernetes_namespace" "mission_control" {
  metadata {
    name = var.namespace
  }
  
}

resource "null_resource" "install_kots_cli" {
  provisioner "local-exec" {
    command = <<EOT
    export KOTS_INSTALL_PATH="$(pwd)/bin"
    mkdir -p $KOTS_INSTALL_PATH
    curl -fsSL https://kots.io/install | REPL_INSTALL_PATH=$KOTS_INSTALL_PATH bash
    export PATH=$KOTS_INSTALL_PATH:\$PATH
    EOT
  }
}

resource "null_resource" "install_cert_manager" {
  depends_on = [null_resource.install_kots_cli, kubernetes_namespace.mission_control, local_file.mission_control_config, var.kubeconfig_path]

  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=${var.kubeconfig_path}
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
    EOT
  }
}

resource "null_resource" "install_kots_admin_console" {
  depends_on = [null_resource.install_kots_cli, kubernetes_namespace.mission_control, local_file.mission_control_config, null_resource.install_cert_manager]

  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=${var.kubeconfig_path}
    kubectl kots install mission-control \
      --namespace "${var.namespace}" \
      --license-file ${var.license_path} \
      --shared-password "${var.shared_password}" \
      --no-port-forward \
      --config-values "${abspath(local_file.mission_control_config.filename)}" \
      --skip-preflights true \
      --wait-duration 5m
    EOT
  }
}
resource "local_file" "mission_control_config" {
  filename = "${path.module}/mission-control-config.yaml"
  content  = <<EOT
apiVersion: kots.io/v1beta1
kind: ConfigValues
metadata:
  name: Mission Control
  namespace: ${var.namespace}
spec:
  values:
    mc_mode:
      value: "control_plane"
    loki_chunks_bucket_name:
      value: "${var.loki_bucket_name}"
    mimir_attached_storage_class:
      value: "linode-block-storage-retain"
    mimir_bucket_name:
      value: "${var.mimir_bucket_name}"
    observability_bucket_backend:
      value: "s3"
    observability_bucket_endpoint:
      value: "${var.s3_endpoint}"
    observability_bucket_region:
      value: "${var.s3_region}"
    observability_bucket_secret_access_key:
      value: "${base64encode(var.s3_secret_key)}"
    observability_enabled:
      default: "1"
    observability_bucket_access_key_id:
      value: "${var.s3_access_key}"
EOT
}

output "namespace" {
  value = "${var.namespace}"
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}