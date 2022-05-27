



data "google_compute_network" "vpc" {
name = var.vpc_name
project = var.project_name
}

output "firewall_rule" {
  value = var.settings
}


resource "google_compute_firewall" "firewall_rule" {
  name      = var.name
  network   = var.vpc_name
  project   = var.project_name
  direction = var.settings.direction
  priority                = lookup(var.settings, "priority", 1000)
  description = try(var.settings.description,"")
  source_ranges           = lookup(var.settings,"direction") == "INGRESS" ? var.settings.ranges : null
  destination_ranges      = var.settings.direction == "EGRESS" ? var.settings.ranges : null
  source_tags             = var.settings.use_service_accounts || var.settings.direction == "EGRESS" ? null : var.settings.sources
  source_service_accounts = var.settings.use_service_accounts && var.settings.direction == "INGRESS" ? var.settings.sources : null
  target_tags             = var.settings.use_service_accounts ? null : var.settings.targets
  target_service_accounts = var.settings.use_service_accounts ? var.settings.targets : null
  disabled                = lookup(var.settings.extra_attributes, "disabled", false)
 

  dynamic "log_config" {
    for_each = lookup(var.settings.extra_attributes, "flow_logs", false) ? [{
      metadata = lookup(var.settings.extra_attributes, "flow_logs_metadata", "INCLUDE_ALL_METADATA")
    }] : []
    content {
      metadata = log_config.value.metadata
    }
  }

  dynamic "allow" {
    for_each = [for rule in var.settings.rules : rule if var.settings.action == "allow"]
    iterator = rule
    content {
      protocol = rule.value.protocol
      ports    = rule.value.ports
    }
  }

  dynamic "deny" {
    for_each = [for rule in var.settings.rules : rule if var.settings.action == "deny"]
    iterator = rule
    content {
      protocol = rule.value.protocol
      ports    = rule.value.ports
    }
  }
}
