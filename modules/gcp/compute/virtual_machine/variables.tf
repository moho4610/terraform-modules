/*
variable names {
  type = list(string)
}

variable machine_type {
}
variable create_instance_group {
  type    = bool
  default = false
}

variable instance_group_names {
  type    = list(string)
  default = ["vmseries-instance-group"]
}
variable zones {
  type = list(string)
}
variable ssh_key {
  default = ""
}
variable image {
}

variable subnetworks {
  type = list(string)
}

variable scopes {
  type = list(string)

  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}

variable startup_script {
  default = ""
}
*/

variable "project_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}

variable "base_labels" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}
variable "settings" {}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
}

variable "storage_buckets" {
  default = {}
}

