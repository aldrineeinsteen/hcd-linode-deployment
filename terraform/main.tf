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

module "kots" {
  source            = "./modules/kots"
  namespace         = "mission-control"
  ingress_enabled   = false
  kubeconfig_path   = module.lke.kubeconfig
  shared_password   = var.shared_password
  license_path      = var.license_path
  s3_access_key     = var.s3_access_key
  s3_endpoint       = var.s3_endpoint
  s3_secret_key     = var.s3_secret_key
  mimir_bucket_name = "mimir-bucket"
  loki_bucket_name  = "loki-bucket"
  s3_region         = "gb-lon"
}

output "mission-control" {
  value = <<EOT

# To access the KOTS admin console, run:
kubectl kots admin-console --namespace mission-control

kubectl get pods -n ${module.kots.namespace}
EOT
}