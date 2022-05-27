
/*
variable health_check_port {
  default = "22"
}

variable backends {
  description = "Map backend indices to list of backend maps."
  type = map(list(object({
    group    = string
    failover = bool
  })))
}

variable subnetworks {
  type = list(string)
}

variable ip_address {
  default = null
}



variable ip_protocol {
  default = "TCP"
}
variable all_ports {
  type = bool
}
variable ports {
  type    = list(string)
  default = []
}

variable network {
  default = null
}

//variable "vpcs" {}
*/

variable "name" {
  description = "Name of the LB"
}

variable "hostname" {
  description = "The hostname of the LB"
}

variable "targetsize" {
  description = "The size of the instance"
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
}

/*
variable "public_ip_addresses" {}

variable "existing_resources" {
  default = {}
}
*/

variable "global_settings" {
  description = "Global settings object (see module README.md)"
}

variable "load_balancer" {
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