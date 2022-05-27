terraform {
  required_version = ">= 0.13.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.50"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.50"
    }
  }

}

locals {
  module_label = {
    "module" = basename(abspath(path.module))
  }
  labels = merge(var.base_labels, local.module_label, try(var.settings.labels, null))

}