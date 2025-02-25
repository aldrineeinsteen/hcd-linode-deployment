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
export KUBECONFIG="${module.lke.kube_config_path}"

# To verify your cluster is working, run:
kubectl get nodes

EOT
}

provider "kubernetes" {
  config_path = module.lke.kube_config_path
  
}

module "kots" {
  source            = "./modules/kots"
  namespace         = "mission-control"
  ingress_enabled   = false
  kubeconfig_path   = module.lke.kube_config_path
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

output "mission_control_ui_endpoints" {
  depends_on = [ module.kots.kots_admin_console ]
  value = [for ip in module.lke.node_external_ips : "https://${ip}:30880/ui/"]
  description = "Mission Control UI endpoints available on all external IPs"
}

module "hcd-deployment" {
  source = "./modules/hcd-cluster"
  kube_config_path = module.lke.kube_config_path
  project_name = var.project_name
  cluster_name = var.cluster_name
  datacenters = var.datacenters
  mission_control_ns = module.kots.namespace
}