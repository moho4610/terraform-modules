terraform {
  required_version = ">= 0.13.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.50"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.50"
    }
  }


  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-network:vpc/v5.0.0"
  }
  provider_meta "google-beta" {
    module_name = "blueprints/terraform/terraform-google-network:vpc/v5.0.0"
  }
}

data "google_compute_zones" "available" {
region = "australia-southeast1"
project = "art-gcve-sandpit"
}

data "google_compute_network" "network" {
name = "vpc-poc-trust"
project = "art-gcve-sandpit"
}

data "google_compute_subnetwork" "subnet" {
  name   = "sb-vpc-poc-australia-southeast1-spoke1"
  region = "australia-southeast1"
   project = "art-gcve-sandpit"
}

output "subnet" {
  value = data.google_compute_subnetwork.subnet
}


module "vm_spoke1" {
  source = "../../../../modules/pal/vm/"
  names  = ["spoke1-vm1", "spoke1-vm2"]
  project = "art-gcve-sandpit"
  tags = ["allow-lb","ssh"]
  zones = [
    data.google_compute_zones.available.names[0],
    data.google_compute_zones.available.names[1]
  ]
  subnetworks           = [data.google_compute_subnetwork.subnet.self_link]
  machine_type          = "f1-micro"
 
  image                 = "https://www.googleapis.com/compute/v1/projects/panw-gcp-team-testing/global/images/ubuntu-2004-lts-apache"
  create_instance_group = true
  //ssh_key               = fileexists(var.public_key_path) ? "${var.spoke_user}:${file(var.public_key_path)}" : ""
  startup_script        = file("../../../../scripts/webserver-startup.sh")
}

module "ilb_web" {
  source            = "../../../../modules/pal/lb_tcp_internal/"
  name              = "spoke1-intlb"
  subnetworks       = [data.google_compute_subnetwork.subnet.self_link]
  all_ports         = false
  ports             = ["80"]
  health_check_port = "80"
  ip_address        = "10.1.0.100"
  project = "art-gcve-sandpit"
  region       = "australia-southeast1"
  backends = {
    "0" = [
      {
        group    = module.vm_spoke1.instance_group[0]
        failover = false
      },
      {
        group    = module.vm_spoke1.instance_group[1]
        failover = false
      }
    ]
  }
}


/*
module "ilb_web" {
  source            = "../../../terraform-modules/modules/pal/lb_tcp_internal/"
  name              = var.spoke1_ilb
  subnetworks       = [module.vpc_spoke1.subnetwork_self_link[0]]
  all_ports         = false
  ports             = ["80"]
  health_check_port = "80"
  ip_address        = var.spoke1_ilb_ip
  project = var.project
  region       = var.regions[0]
  backends = {
    "0" = [
      {
        group    = module.vm_spoke1.instance_group[0]
        failover = false
      },
      {
        group    = module.vm_spoke1.instance_group[1]
        failover = false
      }
    ]
  }
}

resource "google_compute_network_peering" "trust_to_spoke1" {
  name                 = "${var.trust_vpc}-to-${var.spoke1_vpc}"
  provider             = google
  network              = module.vpc_trust.vpc_self_link
  peer_network         = module.vpc_spoke1.vpc_self_link
  export_custom_routes = true
}

resource "google_compute_network_peering" "spoke1_to_trust" {
  name                 = "${var.spoke1_vpc}-to-${var.trust_vpc}"
  provider             = google
  network              = module.vpc_spoke1.vpc_self_link
  peer_network         = module.vpc_trust.vpc_self_link
  import_custom_routes = true

  depends_on = [google_compute_network_peering.trust_to_spoke1]
}
*/


