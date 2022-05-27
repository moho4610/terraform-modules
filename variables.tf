# Global settings
variable "global_settings" {
  description = "Global settings object for the current deployment."
  default = {
    passthrough    = false
    random_length  = 4
    default_region = "region1"
    regions = {
      region1 = "australia-southeast1"
      region2 = "australia-southeast2"
    }
  }
}

variable "environment" {
  description = "Name of the environment."
  type        = string
  default     = "sandpit"
}


variable "projects" {
  description = "Configuration object - projects."
  default     = {}
}



variable "organization_id" {
  description = "Azure AD Tenant ID for the current deployment."
  type        = string
  default     = null
}

variable "current_landingzone_key" {
  description = "Key for the current landing zones where the deployment is executed. Used in the context of landing zone deployment."
  default     = "local"
  type        = string
}

variable "labels" {
  description = "labels to be used for this resource deployment."
  type        = map(any)
  default     = null
}
variable "client_config" {
  default = {}
}

## Storage variables
variable "storage_buckets" {
  description = "Configuration object - Storage account resources"
  default     = {}
}



variable "remote_objects" {
  description = "Allow the landing zone to retrieve remote tfstate objects and pass them to the CAF module."
  default     = {}
}


## Networking variables
variable "networking" {
  description = "Configuration object - networking resources"
  default     = {}
}


## Compute variables
variable "compute" {
  description = "Configuration object - Azure compute resources"
  default = {
    
    
  }
}
