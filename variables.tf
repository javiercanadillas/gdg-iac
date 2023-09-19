variable "project_id" {
  type = string
  description = "GCP Project ID"
}

variable "gcp_services_list" {
  type = list(string)
  description = "GCP Services to enable"
  default = [
    "compute.googleapis.com"
  ]
}

variable "vm_prefix" {
  type        = string
  description = "the common VM names prefix"
  default     = "vm"
}

variable "region" {
  type        = string
  description = "the region where the resources live"
  default     = "europe-west8"
}

variable "create_www_instance" {
  type        = bool
  description = "Whether the www VM should be created."
  default     = false
}

variable "www_instances" {
  type        = map(any)
  description = "The www VMs to create"
  default     = {}
}
