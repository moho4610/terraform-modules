variable "projects" {
  default = {}
}

variable "global_settings" {
  default = {
    default_region = "region1"
    regions = {
      region1 = "australia-southeast1"
      region2 = "australia-southeast2"
    }
  }
}

variable "load_balancers" {
  default = {}

}
variable "labels" {
  default = null
  type    = map(any)
}

variable "landingzone" {
  default = {
    backend_type        = "google"
    global_settings_key = "launchpad"
    level               = "level0"
    key                 = "example"
  }
}

variable "logged_user_objectId" {
  default = null
}
variable "logged_aad_app_objectId" {
  default = null
}

variable "dpac_version" {
  default = null
}


variable "storage_buckets" {
  default = {}
}

variable "vpcs" {
  default = {}
}

variable "virtual_machines" {
  default = {}
}

variable "instance_groups" {
  default = {}
}

variable "instance_templates" {
  default = {}
}