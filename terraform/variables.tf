variable "region" {
  description = "The region where the resources will be created"
  type        = string
}

variable "linode_token" {
  description = "The Linode API token"
  type        = string
  sensitive   = true
}

variable "shared_password" {
  description = "The password to use for KOTS admin page"
  type        = string
}

variable "license_path" {
  description = "The path to the KOTS license file"
  type        = string
}

variable "s3_endpoint" {
  description = "The S3 endpoint"
  type        = string
}

variable "s3_access_key" {
  description = "The S3 access key"
  type        = string
}

variable "s3_secret_key" {
  description = "The S3 secret key"
  type        = string
}