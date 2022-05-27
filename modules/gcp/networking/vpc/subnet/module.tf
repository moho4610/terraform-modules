data "google_compute_network" "vpc" {
  name    = var.vpc_name
  project = var.project_name
}

resource "google_compute_subnetwork" "subnet" {
  name           = var.name
  project        = var.project_name
  network        = var.vpc_name
  ip_cidr_range  = var.ip_cidr_range
  region         = var.region
//  service_endpoints                              = var.service_endpoints
//  enforce_private_link_endpoint_network_policies = try(var.enforce_private_link_endpoint_network_policies, false)
//  enforce_private_link_service_network_policies  = try(var.enforce_private_link_service_network_policies, false)
}