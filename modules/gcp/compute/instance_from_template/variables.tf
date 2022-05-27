
variable "project_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}



variable "base_labels" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}


variable "global_settings" {
  description = "Global settings object (see module README.md)"
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
}




variable "settings" {
  
}