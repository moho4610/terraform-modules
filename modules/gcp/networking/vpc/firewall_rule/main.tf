locals {
  module_label = {
    "module" = basename(abspath(path.module))
  }
  labels = merge(local.module_label, var.labels)
}