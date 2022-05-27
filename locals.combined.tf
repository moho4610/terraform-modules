locals {
  combined_objects_projects        = merge(tomap({ (local.client_config.landingzone_key) = local.projects }), try(var.remote_objects.projects, {}))
  combined_objects_networking      = merge(tomap({ (local.client_config.landingzone_key) = module.networking }), try(var.remote_objects.vnets, {}))
  combined_objects_instance_templates = merge(tomap({ (local.client_config.landingzone_key) = module.instance_templates }), try(var.remote_objects.instance_templates, {}))

}
