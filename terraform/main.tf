module "lke" {
  source       = "./modules/lke"
  cluster_name = "hcd-cluster"
  region       = var.region
  linode_token = var.linode_token
}

module "object-store" {
  source       = "./modules/object-store"
  region       = var.region
  linode_token = var.linode_token
}

output "kubeconfig" {
  value = <<EOT

# Run the following command to configure kubectl:
export KUBECONFIG="${module.lke.kubeconfig}"

# To verify your cluster is working, run:
kubectl get nodes

EOT
}