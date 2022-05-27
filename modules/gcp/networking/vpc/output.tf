
output "id" {
  value       = google_compute_network.vpc.id
  description = "VPC id"
}

output "name" {
  value       = google_compute_network.vpc.name
  description = "VPC name"
}


output "project_name" {
  value       = google_compute_network.vpc.project
  description = "VPC resource_group_name"

}
/*
output "region" {
  value       = var.region
  description = "GCP Region of the VPC"
}
*/


output "subnets" {
  description = "Returns all the subnets objects in the VPC. As a map of keys, ID"
  value       = merge(module.subnets)

}

output "firewall_rules" {
  value = (module.firewall_rules)
  
}

output "settings" {
  description = "Returns all the subnets objects in the VPC. As a map of keys, ID"
  value       = var.settings

}
