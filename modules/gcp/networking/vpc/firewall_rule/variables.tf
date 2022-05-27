variable "name" {
  description = "(Required) The name of the subnet. Changing this forces a new resource to be created."
}
variable "project_name" {
  description = "(Required) The name of the project in which to create the subnet."
  type        = string
}
variable "vpc_name" {
  description = "(Required) The name of the vpc to which to attach the subnet."
}
variable "labels" {
  description = "(Required) map of labels for the deployment"
}



variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "settings" {}