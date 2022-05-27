
resource "random_string" "prefix" {
  count   = try(var.global_settings.prefix, null) == null ? 1 : 0
  length  = 4
  special = false
  upper   = false
  number  = false
}

locals {
  global_settings = merge({
    default_region     = try(var.global_settings.default_region, "region1")
    environment        = try(var.global_settings.environment, var.environment)
    inherit_labels       = try(var.global_settings.inherit_labels, false)
    passthrough        = try(var.global_settings.passthrough, false)
    prefix             = try(var.global_settings.prefix, null)
    prefix_with_hyphen = try(var.global_settings.prefix_with_hyphen, format("%s-", try(var.global_settings.prefix, try(var.global_settings.prefixes[0], random_string.prefix.0.result))))
    prefixes           = try(var.global_settings.prefix, null) == "" ? null : try([var.global_settings.prefix], try(var.global_settings.prefixes, [random_string.prefix.0.result]))
    random_length      = try(var.global_settings.random_length, 0)
    regions            = try(var.global_settings.regions, null)
    labels               = try(var.global_settings.labels, null)
    use_slug           = try(var.global_settings.use_slug, true)
  }, var.global_settings)




 client_config = var.client_config == {} ? {
    //client_id               = data.azurerm_client_config.current.client_id
    landingzone_key         = var.current_landingzone_key
    //logged_aad_app_objectId = local.object_id
    //logged_user_objectId    = local.object_id
    //object_id               = local.object_id
    //subscription_id         = data.azurerm_client_config.current.subscription_id
    //tenant_id               = data.azurerm_client_config.current.tenant_id
  } : map(var.client_config)



  networking = {
    /*
    azurerm_routes                                          = try(var.networking.azurerm_routes, {})
    ip_groups                                               = try(var.networking.ip_groups, {})
    lb                                                      = try(var.networking.lb, {})
    lb_backend_address_pool                                 = try(var.networking.lb_backend_address_pool, {})
    lb_backend_address_pool_address                         = try(var.networking.lb_backend_address_pool_address, {})
    lb_nat_pool                                             = try(var.networking.lb_nat_pool, {})
    lb_nat_rule                                             = try(var.networking.lb_nat_rule, {})
    lb_outbound_rule                                        = try(var.networking.lb_outbound_rule, {})
    lb_probe                                                = try(var.networking.lb_probe, {})
    lb_rule                                                 = try(var.networking.lb_rule, {})
    load_balancers                                          = try(var.networking.load_balancers, {})
    network_security_group_definition                       = try(var.networking.network_security_group_definition, {})
    public_ip_addresses                                     = try(var.networking.public_ip_addresses, {})
    route_tables                                            = try(var.networking.route_tables, {})
    vnet_peerings                                           = try(var.networking.vnet_peerings, {})
    */
    vpcs                                                   = try(var.networking.vpcs, {})
    network_firewall_rule_definition                       = try(var.networking.network_firewall_rule_definition, {})
    load_balancers                                         = try(var.networking.load_balancers, {})
  }
  compute = {
    virtual_machines                    = try(var.compute.virtual_machines, {})
    instance_groups                   = try(var.compute.instance_groups, {})
    instance_templates = try(var.compute.instance_templates,{})
    //virtual_machine_scale_sets          = try(var.compute.virtual_machine_scale_sets, {})
  }


}


