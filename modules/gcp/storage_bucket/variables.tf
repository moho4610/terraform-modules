variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "storage_bucket" {
  default = {}

}
variable "project_name" {
  description = "(Required) The name of the project where to create the resource."
  type        = string
 
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "projects" {
  default = {}
}

variable "base_labels" {
  default = {}
}