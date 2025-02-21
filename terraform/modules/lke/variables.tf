variable "cluster_name" {
    description = "The name of the Linode Kubernetes Engine (LKE) cluster."
    type        = string
}

variable "region" {
    description = "The region where the LKE cluster will be deployed."
    type        = string
}

variable "linode_token" {
    description = "The Linode API token used for authentication."
    type        = string
    sensitive   = true
}