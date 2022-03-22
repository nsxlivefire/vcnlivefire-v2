terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
      version = "3.2.5"
      configuration_aliases = [ nsxt.alternate ]
    }
    avi = {
      source  = "vmware/avi"
      version = "21.1.3"
    }
  }
}

# Site-A NSX Manager provider setup
provider "nsxt" {
  host                  = "192.168.110.15"
  username              = "admin"
  password              = "VMware1!VMware1!"
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

# Global NSX Manager provider setup
provider "nsxt" {
  host           = "192.168.110.16"
  username       = "admin"
  password       = "VMware1!VMware1!"
  global_manager = true
  alias = "global_manager"
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
}

# Avi provider setup
provider "avi" {
        avi_controller          = var.avi_controller
        avi_username            = var.avi_username
        avi_password            = var.avi_password
        avi_version             = var.avi_version
        avi_tenant              = "admin"
}
