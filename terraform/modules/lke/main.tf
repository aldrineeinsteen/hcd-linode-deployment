terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
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

resource "null_resource" "label_one_node" {
  depends_on = [linode_lke_cluster.hcd_cluster]

  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=${abspath(local_file.kube_config_file.filename)}
    
    # Wait for nodes to be ready
    echo "⏳ Waiting for nodes to be ready..."
    sleep 60
    
    # Get the first available node dynamically
    PLATFORM_NODE=$(kubectl get nodes --no-headers -o custom-columns=":metadata.name" | head -n 1)
    
    if [[ -n "$PLATFORM_NODE" ]]; then
      echo "🔹 Labeling node $PLATFORM_NODE as platform"
      kubectl label nodes $PLATFORM_NODE mission-control.datastax.com/role=platform --overwrite
      echo "✅ Node $PLATFORM_NODE labeled as platform"
    else
      echo "❌ No nodes found. Check your cluster setup."
      exit 1
    fi
    EOT
  }
}


resource "local_file" "kube_config_file" {
  # filename = "${path.module}/kubeconfig"
  content  = base64decode(linode_lke_cluster.hcd_cluster.kubeconfig)
  filename = "${path.module}/kubeconfig.yaml"
}

output "kube_config_path" {
  value = abspath(local_file.kube_config_file.filename)
}