resource "google_compute_instance_from_template" "compute_instance" {
  for_each = var.settings.instance_group_settings
  name    = each.value.name
  project = var.project_name
  zone    = each.value.zone

  dynamic "network_interface" {
    for_each = try(each.value.networking_interfaces, {})

    content {
      network            = network_interface.value.network
      subnetwork         = network_interface.value.subnetwork
      subnetwork_project = network_interface.value.subnetwork_project
      //network_ip         = length(var.static_ips) == 0 ? "" : element(local.static_ips, count.index)
      dynamic "access_config" {
        for_each = network_interface.value.access_config
        content {
          nat_ip       = access_config.value.nat_ip
          network_tier = access_config.value.network_tier
        }
      }
    }

  }

  source_instance_template = each.value.instance_template
}