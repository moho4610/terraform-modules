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



#project = "art-gcve-sandpit"
#location = "australia-southeast1"  
#bucket_name = "fw-bootstrap-common"


module "bootstrap_common" {
  source        = "../../../modules/pan/"
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
  names  = var.fw_names_common
  project = var.project
  zones = [
    data.google_compute_zones.available.names[0],
    data.google_compute_zones.available.names[1]
  ]
  subnetworks = [
    module.vpc_untrust.subnetwork_self_link[0],
    module.vpc_mgmt.subnetwork_self_link[0],
    module.vpc_trust.subnetwork_self_link[0]
  ]
  machine_type          = var.fw_machine_type
  bootstrap_bucket      = module.bootstrap_common.bucket_name
  mgmt_interface_swap   = "enable"
  ssh_key               = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  image                 = "${var.fw_image}-${var.fw_panos}"
  nic0_public_ip        = true
  nic1_public_ip        = true
  nic2_public_ip        = false
  create_instance_group = true

  dependencies = [
    module.bootstrap_common.completion,
  ]
}

module "lb_inbound" {
  source       = "../../../terraform-modules/modules/pal/lb_tcp_external/"
  region       = var.regions[0]
  name         = var.extlb_name
  service_port = 80
  instances    = module.fw_common.vm_self_link
  project = var.project
 
}

#-----------------------------------------------------------------------------------------------
# Create 2 internal load balancers. LB-1 is A/A for internet.  LB-2 is A/P for e-w.
module "lb_outbound" {
  source            = "../../../terraform-modules/modules/pal/lb_tcp_internal/"
  name              = var.intlb_name
  subnetworks       = [module.vpc_trust.subnetwork_self_link[0]]
  all_ports         = true
  ports             = []
  health_check_port = "22"
  network           = module.vpc_trust.vpc_id
  project = var.project
  region       = var.regions[0]

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
  name         = "${var.intlb_name}-default"
  dest_range   = "0.0.0.0/0"
  network      = module.vpc_trust.vpc_self_link
  next_hop_ilb = module.lb_outbound.forwarding_rule[0]
  priority     = 99
  provider     = google
  project = var.project
}

resource "google_compute_route" "eastwest" {
  name         = "${var.intlb_name}-eastwest"
  dest_range   = "10.0.0.0/8"
  network      = module.vpc_trust.vpc_self_link
  next_hop_ilb = module.lb_outbound.forwarding_rule[1]
  priority     = 99
  provider     = google
  project = var.project
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

