variable "kube_config_path" {
  description = "value of KUBECONFIG environment variable"
  type        = string  
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "datacenters" {
  description = "List of datacenters"
  type = list(object({
    datacenterName  = string
    num_racks       = number
    nodes_per_rack  = number
  }))
}

variable "mission_control_ns" {
  description = "Namespace for Mission Control"
  type        = string
}