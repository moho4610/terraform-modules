
module "example" {
  source          = "../../.."
  global_settings = var.global_settings
  projects        = var.projects
  labels          = local.labels
  //storage_buckets = var.storage_buckets
  networking = {
    vpcs           = var.vpcs
    load_balancers = var.load_balancers

  }
  compute = {
    instance_groups    = var.instance_groups
    virtual_machines   = var.virtual_machines
    instance_templates = var.instance_templates
  }

}
