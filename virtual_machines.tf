
module "virtual_machines" {
  source = "./modules/gcp/compute/virtual_machine"
    depends_on = [
    module.networking
    
  ]

  for_each = local.compute.virtual_machines 
  settings                    = each.value
  project_name = can(each.value.project.name) || can(each.value.project_name) ? try(each.value.project.name, each.value.project_name) : local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project_key, each.value.project.key)].name
  base_labels           = try(local.global_settings.inherit_labels, false) ? local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project.key, each.value.project_key)].labels : {}
  global_settings             = local.global_settings
  client_config               = local.client_config
  // instance_groups           = local.combined_objects_instance_groups
}



output "virtual_machines" {
  value = module.virtual_machines

}


