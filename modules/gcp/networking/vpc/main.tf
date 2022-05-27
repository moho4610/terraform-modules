locals {
  module_label = {
    "module" = basename(abspath(path.module))
  }
  labels = merge(var.base_labels, local.module_label, var.labels)
}
