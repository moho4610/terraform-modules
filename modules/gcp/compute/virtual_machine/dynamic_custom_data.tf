locals {
  dynamic_custom_data = {
    palo_alto_connection_string = {
      for item in var.settings.virtual_machine_settings :
      item.name => base64encode("storage-bucket=${var.storage_buckets[var.client_config.landingzone_key][item.palo_alto_connection_string.storage_bucket].name}, access-key=${var.storage_buckets[var.client_config.landingzone_key][item.palo_alto_connection_string.storage_buckets].primary_access_key}, file-share=${var.storage_buckets[var.client_config.landingzone_key][item.palo_alto_connection_string.storage_buckets].file_share[item.palo_alto_connection_string.file_share].name}, share-directory=${var.storage_buckets[var.client_config.landingzone_key][item.palo_alto_connection_string.storage_bucket].file_share[item.palo_alto_connection_string.file_share].file_share_directories[item.palo_alto_connection_string.file_share_directory].name}")
      if try(item.palo_alto_connection_string, null) != null
    }
  }
}
