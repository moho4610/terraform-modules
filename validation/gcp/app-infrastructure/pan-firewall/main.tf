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


}

variable fw_image {
  default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries"
}
variable fw_panos {
  description = "VM-Series license and PAN-OS (ie: bundle1-814, bundle2-814, or byol-814)"
default = "flex-bundle1-1002" 
}

data "google_compute_zones" "available" {
region = "australia-southeast1"
project = "art-gcve-sandpit"
}

data "google_compute_network" "vpc_public" {
name = "vpc-poc-untrust"
project = "art-gcve-sandpit"
}

data "google_compute_network" "vpc_hub" {
name = "vpc-poc-trust"
project = "art-gcve-sandpit"
}


data "google_compute_subnetwork" "subnet_untrust" {
  name   = "sb-vpc-poc-australia-southeast1-untrust"
  region = "australia-southeast1"
   project = "art-gcve-sandpit"
}

data "google_compute_subnetwork" "subnet_hub" {
  name   = "sb-vpc-poc-australia-southeast1-trust"
  region = "australia-southeast1"
   project = "art-gcve-sandpit"
}


data "google_compute_subnetwork" "subnet_mgmt" {
  name   = "sb-vpc-poc-australia-southeast1-mgmt"
  region = "australia-southeast1"
   project = "art-gcve-sandpit"
}


###################################################
# Bootstrap Storage
###################################################
module "bootstrap_common" {
  source        = "../../../../modules/pan/modules/gcp_bootstrap/"
  bucket_name   = "bkt-poc-art-gcve-sandpit-pan"
  file_location = "C:/Users/michelle.munro/source/repos/AustralianRetirementTrust/terraform-modules/modules/pan/bootstrap_files/"
  config        = ["init-cfg.txt", "bootstrap.xml"]
  license       = ["authcodes"]
  project =  "art-gcve-sandpit"
  location = "australia-southeast1"
   
}



#-----------------------------------------------------------------------------------------------
# Create  firewalls
module "fw_common" {
  source = "../../../../modules/pal/vmseries/"
  names  = ["vm-fw-01","vm-fw-02"]
  project = "art-gcve-sandpit"
  zones = [
    data.google_compute_zones.available.names[0],
    data.google_compute_zones.available.names[1]
  ]
  subnetworks = [
    data.google_compute_subnetwork.subnet_untrust.self_link,
    data.google_compute_subnetwork.subnet_mgmt.self_link,
    data.google_compute_subnetwork.subnet_hub.self_link
  ]
  machine_type          = "n1-standard-4"
  tags = ["allow-lb"]
  bootstrap_bucket      = module.bootstrap_common.bucket_name
  mgmt_interface_swap   = "enable"
  //ssh_key               = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  ssh_key = ""
  //image                 = "${var.fw_image}-${var.fw_panos}"
  image =  "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-bundle1-1002" 
  nic0_public_ip        = true
  nic1_public_ip        = true
  nic2_public_ip        = false
  create_instance_group = true

  dependencies = [
    module.bootstrap_common.completion,
  ]
}

module "lb_inbound" {
  source       = "../../../../modules/pal/lb_tcp_external/"
  region       = "australia-southeast1"
  name         = "lb-ext"
  service_port = 80
  instances    = module.fw_common.vm_self_link
  project = "art-gcve-sandpit"
 
}

#-----------------------------------------------------------------------------------------------
# Create 2 internal load balancers. LB-1 is A/A for internet.  LB-2 is A/P for e-w.
module "lb_outbound" {
  source            = "../../../../modules/pal/lb_tcp_internal/"
  name              = "lb-int"
  subnetworks       = [data.google_compute_subnetwork.subnet_hub.self_link]
  all_ports         = true
  ports             = []
  health_check_port = "22"
  network           = data.google_compute_network.vpc_hub.id
  project = "art-gcve-sandpit"
  region       = "australia-southeast1"

  backends = {
    "0" = [
      {
        group    = module.fw_common.instance_group[0]
        failover = false
      },
      {
        group    = module.fw_common.instance_group[1]
        failover = false
      }
    ]
    "1" = [
      {
        group    = module.fw_common.instance_group[0]
        failover = false
      },
      {
        group    = module.fw_common.instance_group[1]
        failover = true
      }
    ]
  }
}


#-----------------------------------------------------------------------------------------------
# Create routes route to internal LBs. Routes will be exported to spokes via GCP peering.
resource "google_compute_route" "default" {
  name         = "lb-int-default"
  dest_range   = "0.0.0.0/0"
  network      = data.google_compute_network.vpc_hub.self_link
  next_hop_ilb = module.lb_outbound.forwarding_rule[0]
  priority     = 99
  provider     = google
  project = "art-gcve-sandpit"
}

resource "google_compute_route" "eastwest" {
  name         = "lb-int-eastwest"
  dest_range   = "10.0.0.0/8"
  network      = data.google_compute_network.vpc_hub.self_link
  next_hop_ilb = module.lb_outbound.forwarding_rule[1]
  priority     = 99
  provider     = google
  project = "art-gcve-sandpit"
}


#-----------------------------------------------------------------------------------------------
# Outputs to terminal
output EXT-LB {
  value = "http://${module.lb_inbound.forwarding_rule_ip_address}"
}

output MGMT-FW1 {
  value = "https://${module.fw_common.nic1_public_ip[0]}"
}

output MGMT-FW2 {
  value = "https://${module.fw_common.nic1_public_ip[1]}"
}






