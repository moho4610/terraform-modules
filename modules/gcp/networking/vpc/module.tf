resource "google_compute_network" "vpc" {
  name                            = var.settings.vpc.name
  auto_create_subnetworks         = var.settings.vpc.auto_create_subnetworks
  routing_mode                    = var.settings.vpc.routing_mode
  project                         = var.project_name
  delete_default_routes_on_create = var.settings.vpc.delete_default_routes_on_create
  mtu                             = var.settings.vpc.mtu
}

module "subnets" {
  source = "./subnet"
  for_each                                = lookup(var.settings, "subnets", {})
  name                                    = each.value.name
  global_settings                         = var.global_settings
  project_name                            = var.project_name
  vpc_name                                = google_compute_network.vpc.name
  ip_cidr_range                           = lookup(each.value, "ip_cidr_range", [])
  region                                  = lookup(each.value, "region", "")
  settings                                = each.value
}

module "firewall_rules" {
  source = "./firewall_rule"
  for_each                                = lookup(var.settings, "network_firewall_rules", {})
  name                                    = each.value.name
  global_settings                         = var.global_settings
  project_name                            = var.project_name
  vpc_name                                = google_compute_network.vpc.name
  settings                                = each.value
  labels = local.labels
}
