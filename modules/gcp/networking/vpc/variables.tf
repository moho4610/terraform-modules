variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "vpc" {
  default = {}
}

variable "project_name" {
  description = "(Required) The name of the project where to create the resource."
  type        = string
}

variable "region" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "projects" {
  default = {}
}

variable "labels" {
  description = "(Required) map of labels for the deployment"
}

variable "base_labels" {
  default = {}
}

variable "settings" {
  description = "(Required) configuration object describing the networking configuration, as described in README"
}