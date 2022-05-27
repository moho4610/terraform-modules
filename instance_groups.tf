



module "instance_groups" {
  source   = "./modules/gcp/compute/instance_group"
  depends_on = [
    module.virtual_machines
  ]
  for_each = local.compute.instance_groups
    global_settings            = local.global_settings
    client_config              = local.client_config
    settings                   = each.value
    project_name        = can(each.value.project.name) || can(each.value.project_name) ? try(each.value.project.name, each.value.project_name) : local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project_key, each.value.project.key)].name
    base_labels                  = try(local.global_settings.inherit_labels, false) ? local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project.key, each.value.project_key)].labels : {}
    virtual_machines = module.virtual_machines
  
}


output "instance_groups" {
  value = module.instance_groups
}