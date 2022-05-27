
 

module "load_balancer" {
  source            = "./modules/gcp/networking/load_balancer"
  for_each = try(local.networking.load_balancers, {})
  //name              = var.settings.name
  project_name = can(each.value.project.name) || can(each.value.project_name) ? try(each.value.project.name, each.value.project_name) : local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project_key, each.value.project.key)].name
  base_labels           = try(local.global_settings.inherit_labels, false) ? local.combined_objects_projects[try(each.value.project.lz_key, local.client_config.landingzone_key)][try(each.value.project.key, each.value.project_key)].labels : {}
  client_config       = local.client_config
  //vpcs               = local.combined_objects_networking
  global_settings     = local.global_settings
  settings            = each.value
  labels              = try(each.value.labels, null)
  hostname              = try(each.value.hostname, null)
  targetsize              = try(each.value.targetsize, null)
  region              = try(each.value.region, null)
  name              = try(each.value.name, null)
}
  //subnetworks       = [module.vpc_trust.subnetwork_self_link[0]]
 // all_ports         = true
 // ports             = []
 // health_check_port = "22"
 // network           = module.vpc_trust.vpc_id
/*
  backends = {
    "0" = [
      {
        group    = module.fw_common.instance_group[0]
        failover = false
      },
      {
        group    = module.fw_common.instance_group[1]
        failover = false
      }
    ]
    "1" = [
      {
        group    = module.fw_common.instance_group[0]
        failover = false
      },
      {
        group    = module.fw_common.instance_group[1]
        failover = true
      }
    ]
  }
}
*/

output "load_balancer" {
  value = module.load_balancer
}
