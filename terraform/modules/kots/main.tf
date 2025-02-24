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

resource "null_resource" "install_kots_admin_console" {
  depends_on = [null_resource.install_kots_cli, kubernetes_namespace.mission_control]

  provisioner "local-exec" {
    command = <<EOT
    kubectl kots install mission-control \
      --namespace "${var.namespace}" \
      --license-file ${var.license_path} \
      --shared-password "${var.shared_password}" \
      --no-port-forward \
      --wait-duration 5m
    EOT
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}