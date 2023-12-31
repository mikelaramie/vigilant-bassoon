variable "bankofanthos" {
  type        = bool
  description = "Deploy the Bank of Anthos demo application?  Defaults to false."
  default     = false
}

variable "bankofanthos_namespace" {
  type = string
  description = "Namespace to deploy the Bank of Anthos app to"
  default = "bankofanthos"
}

variable "create_aoss_java_repository" {
  type        = bool
  description = "Deploy the Assured Open Source Software Java repository?  Defaults to false."
  default     = false
}

variable "create_aoss_python_repository" {
  type        = bool
  description = "Deploy the Assured Open Source Software Python repository?  Defaults to false."
  default     = false
}

variable "create_bankofanthos_repository" {
  type        = bool
  description = "Deploy the Bank of Anthos repository?  Defaults to false."
  default     = false
}

variable "enable_cloudarmor" {
  type        = bool
  description = "Boolean to enable/disable Cloud Armor on the Bank of Anthos application.  Defaults to false."
  default     = false
}

variable "enable_iap" {
  type        = bool
  description = "Enable Identity-Aware Proxy settings within the project and expose an IAP-protected Ingress"
  default     = false
}

variable "gcp_gar_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "artifactregistry.googleapis.com"
  ]
}

variable "gcp_gke_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com"
  ]
}

variable "project_id" {
  type        = string
  description = "Project to deploy resources in"
}

variable "region" {
  type        = string
  description = "Default region to use for resources"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Default zone to use for resources"
  default     = "us-central1-b"
}
