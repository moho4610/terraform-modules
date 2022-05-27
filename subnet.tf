
/*
output "vpcs" {
  value      = module.networking
}
*/

module "subnet" {
  depends_on = []
  source     = "./modules/gcp/networking/vpc/subnet"
  for_each   = local.subnets
  name              = try(each.value.name, null)
  project              = try(each.value.project, null)
  network              = try(each.value.network, null)
  ip_cidr_range              = try(each.value.ip_cidr_range, null)
  region     = lookup(each.value, "region", null) == null ? local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project.key, each.value.project_key)].location : local.global_settings.regions[each.value.region]
  
  //application_security_groups       = local.combined_objects_application_security_groups
  client_config                     = local.client_config
  //ddos_id                           = try(local.combined_objects_ddos_services[try(each.value.ddos_services_lz_key, local.client_config.landingzone_key)][try(each.value.ddos_services_key, each.value.ddos_services_key)].id, "")
  //diagnostics                       = local.combined_diagnostics
  global_settings                   = local.global_settings
  //network_security_groups           = module.network_security_groups
  //network_security_group_definition = local.networking.network_security_group_definition
  //network_watchers                  = local.combined_objects_network_watchers
  //route_tables                      = module.route_tables
  settings                          = each.value
  labels                              = try(each.value.labels, null)

  project_name = local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project.key, each.value.project_key)].name
  //base_tags           = try(local.global_settings.inherit_tags, false) ? local.combined_objects_projects[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags : {}

 
}