

resource "google_compute_instance" "vm" {
  
  for_each = local.os_type == "linux" ? var.settings.virtual_machine_settings : {}
  name     = each.value.name
  project  = var.project_name
  machine_type              = each.value.machine_type
  zone                      = each.value.zone
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script = try(
    local.dynamic_custom_data[each.value.custom_data][each.value.name],
    try(filebase64(format("%s/%s", path.cwd, each.value.custom_data)), base64encode(each.value.custom_data)),
    null
  )

  metadata = {
    serial-port-enable = true
    //ssh-keys           = var.ssh_key
  }

  boot_disk {
    initialize_params {
      image = each.value.image
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
}


 //availability_set_id             = can(each.value.availability_set_key) || can(each.value.availability_set.key) ? var.availability_sets[try(var.client_config.landingzone_key, each.value.availability_set.lz_key)][try(each.value.availability_set_key, each.value.availability_set.key)].id : try(each.value.availability_set.id, each.value.availability_set_id, null)
  