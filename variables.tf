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
