variable "namespace" {
    description = "The namespace in which to deploy the Helm release"
    type        = string
}

variable "ingress_enabled" {
    description = "Enable or disable ingress for the Helm release"
    type        = bool
    default     = false
}

variable "kubeconfig_path" {
    description = "The kubeconfig file to use for the Helm release"
    type        = string
}

variable "shared_password" {
    description = "The password to use for the KOTS admin page"
    type        = string
}

variable "license_path" {
    description = "The path to the KOTS license file"
    type        = string
}

variable "mimir_bucket_name" {
    description = "The name of the Mimir bucket"
    type        = string
}

variable "loki_bucket_name" {
    description = "The name of the Loki bucket"
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

variable "s3_region" {
    description = "The S3 region"
    type        = string
}