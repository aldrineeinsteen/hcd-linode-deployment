variable "region" {
  description = "The region where the resources will be created"
  type        = string
}

variable "linode_token" {
  description = "The Linode API token"
  type        = string
  sensitive   = true
}