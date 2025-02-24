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