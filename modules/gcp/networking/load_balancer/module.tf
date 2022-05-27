resource "google_compute_health_check" "default" {
  name = "${var.settings.name}-check-0"
  project = var.project_name

  tcp_health_check {
    port = var.settings.health_check_port
  }
}

module "load_balancer" {
  source       = "GoogleCloudPlatform/lb/google"
  version      = "~> 2.0.0"
  region       = var.settings.load_balancer.region
  name         = var.settings.load_balancer.name
  service_port = 80
  target_tags  = ["allow-lb-service"]
  network      = var.settings.load_balancer.network
}

module "managed_instance_group" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 1.0.0"
  region            = var.settings.load_balancer.region
  target_size       = var.settings.load_balancer.targetsize
  hostname          = var.settings.load_balancer.hostname
  instance_template = "./modules/gcp/compute/instance_template"
  target_pools      = [module.load_balancer.target_pool]
  named_ports = [{
    name = "http"
    port = 80
  }]
}

# module "vm_instance_template" {
#   source  = "terraform-google-modules/vm/google//modules/instance_template"
#   version = "7.7.0"
#   # insert the 8 required variables here
# }

# module "gcp-lb-front" {
#   source       = "github.com/GoogleCloudPlatform/terraform-google-lb"
#   region       = var.region
#   name         = var.name
#   service_port = module.mig1.service_port
#   target_tags  = [module.mig1.target_tags]
# }

/*
resource "google_compute_region_backend_service" "default" {
//  count         = length(var.backends)
  name          = "${var.name}-${count.index}"
  health_checks = [google_compute_health_check.default.self_link]
  network       = var.settings.network

  dynamic "backend" {
    for_each = var.backends[count.index]
    content {
      group    = lookup(backend.value, "group")
      failover = lookup(backend.value, "failover")
    }
  }
  session_affinity = "NONE"
}

resource "google_compute_forwarding_rule" "default" {
  count                 = length(var.backends)
  name                  = "${var.name}-all-${count.index}"
  load_balancing_scheme = "INTERNAL"
  ip_address            = var.ip_address
  ip_protocol           = var.ip_protocol
  all_ports             = var.all_ports
  ports                 = var.ports
  subnetwork            = var.subnetworks[0]
  backend_service       = google_compute_region_backend_service.default[count.index].self_link
}
*/