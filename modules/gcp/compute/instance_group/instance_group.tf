



//each.value.instances


resource "google_compute_instance_group" "default" {
 name = var.settings.name
 zone = var.settings.zone 
 project = var.project_name
 instances = local.instances
 
  named_port {
    name = var.settings.named_port.name
    port = var.settings.named_port.port
  }

  lifecycle {
    create_before_destroy = true
  }
}

