


module "projects" {
  source = "./modules/gcp/project"
  for_each = {
    for key, value in try(var.projects, {}) : key => value
    if try(value.reuse, false) == false
  }

  project_name = each.value.name
  settings            = each.value
  global_settings     = local.global_settings
  labels                = merge(lookup(each.value, "labels", {}), var.labels)
}

module "project_reused" {
  depends_on = [module.projects]
  source     = "./modules/gcp/project_reused"
  for_each = {
    for key, value in try(var.projects, {}) : key => value
    if try(value.reuse, false) == true
  }

  settings = each.value
}

locals {
  projects = merge(module.projects, module.project_reused)
}

output "projects" {
  value = local.projects
}

