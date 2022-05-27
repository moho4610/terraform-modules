module "storage_buckets" {
  source   = "./modules/gcp/storage_bucket"
  for_each = var.storage_buckets

  global_settings   = local.global_settings
  client_config     = local.client_config
  storage_bucket   = each.value
 
  //vnets             = local.combined_objects_networking
  //private_endpoints = try(each.value.private_endpoints, {})
  projects   = local.projects
  //recovery_vaults   = local.combined_objects_recovery_vaults
  //private_dns       = local.combined_objects_private_dns

  //location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project.key, each.value.project_key)].location
  location = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : "australia-southeast1" //local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project.key, each.value.project_key)].location
  //location = "australia-southeast1"
  project_name = can(each.value.project.name) || can(each.value.project_name) ? try(each.value.project.name, each.value.project_name) : local.combined_objects_projects[try(each.value.projects.lz_key, local.client_config.landingzone_key)][try(each.value.project_key, each.value.project.key)].name
   base_labels           = try(local.global_settings.inherit_labels, false) ? local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project.key, each.value.project_key)].labels : {}

}

output "storage_buckets" {
  value = module.storage_buckets

}
