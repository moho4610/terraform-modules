variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "labels" {
  description = "(Required) Map of labels to be applied to the resource"
  type        = map(any)
}
variable "settings" {}
variable "project_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
