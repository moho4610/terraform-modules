
locals {
  os_type = lower(var.settings.os_type)
  # Generate SSH Keys only if a public one is not provided
  create_sshkeys = (local.os_type == "linux" || local.os_type == "legacy") && try(var.settings.public_key_pem_file == "", true)
  module_label = {
    "module" = basename(abspath(path.module))
  }
  labels = merge(var.base_labels, local.module_label, try(var.settings.labels, null))
}