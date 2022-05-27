
#########
# Locals
#########
output "name" {
  value = var.settings
}
####################
# Instance Template
####################

resource "google_compute_instance_template" "tpl" {
  for_each                = var.settings.instance_template_settings
  //name_prefix             = "${each.value.name_prefix}-"
  name = each.value.name
  project                 = var.project_name
  machine_type            = each.value.machine_type
  labels                  = each.value.labels
  metadata                = each.value.metadata
  tags                    = each.value.tags
  can_ip_forward          = each.value.can_ip_forward
  metadata_startup_script = each.value.custom_data
  region                  = each.value.region
  min_cpu_platform        = each.value.min_cpu_platform

  dynamic "disk" {

    for_each = try(each.value.disks, {})
    content {
      auto_delete  = lookup(disk.value, "auto_delete", null)
      boot         = lookup(disk.value, "boot", null)
      device_name  = lookup(disk.value, "device_name", null)
      disk_name    = lookup(disk.value, "disk_name", null)
      disk_size_gb = lookup(disk.value, "disk_size_gb", lookup(disk.value, "disk_type", null) == "local-ssd" ? "375" : null)
      disk_type    = lookup(disk.value, "disk_type", null)
      interface    = lookup(disk.value, "interface", lookup(disk.value, "disk_type", null) == "local-ssd" ? "NVME" : null)
      mode         = lookup(disk.value, "mode", null)
      source       = lookup(disk.value, "source", null)
      source_image = lookup(disk.value, "source_image", null)
      type         = lookup(disk.value, "disk_type", null) == "local-ssd" ? "SCRATCH" : "PERSISTENT"
      labels       = lookup(disk.value, "disk_labels", null)

      dynamic "disk_encryption_key" {
        for_each = compact([each.value.disk_encryption_key == null ? null : 1])
        content {
          kms_key_self_link = each.value.disk_encryption_key
        }
      }
    }
  }

  service_account {
    scopes = each.value.service_account.scopes
  }


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

  lifecycle {
    create_before_destroy = "true"
  }

}
