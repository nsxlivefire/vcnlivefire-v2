terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
      version = "3.2.5"
    }
  }
}

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


data "nsxt_policy_tier1_gateway" "t1-internal" {
  display_name = "t1-internal"
}

data "nsxt_policy_group" "mgmt" {
  display_name = "mgmt"
}

data "nsxt_policy_group" "alb-a-ControllerCluster" {
  display_name = "alb-a-ControllerCluster"
}

data "nsxt_policy_group" "alb-a-ServiceEngineMgmtIPs" {
  display_name = "alb-a-ServiceEngineMgmtIPs"
}

data "nsxt_policy_group" "alb-a-ServiceEngines" {
  display_name = "alb-a-ServiceEngines"
}

#data "nsxt_policy_group" "web" {
#  display_name = "web"
#}

resource "nsxt_policy_group" "dmz" {
  nsx_id       = "dmz"
  display_name = "dmz"
  criteria {
    condition {
      member_type = "Segment"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "zone|dmz"
    }
  }
}

resource "nsxt_policy_group" "internal" {
  nsx_id       = "internal"
  display_name = "internal"
  criteria {
    condition {
      member_type = "Segment"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "zone|internal"
    }
  }
}

resource "nsxt_policy_service" "couchdb" {
  display_name = "couchdb"

  l4_port_set_entry {
    display_name      = "TCP5984"
    description       = "TCP port 5984 entry"
    protocol          = "TCP"
    destination_ports = ["5984"]
  }
}

resource "nsxt_policy_gateway_policy" "InternalZone" {
  display_name    = "Macro Segmentation for Internal Zone"
  category        = "LocalGatewayRules"
  locked          = false
  sequence_number = 1
  stateful        = true
  tcp_strict      = true

  rule {
    display_name       = "Allow Management"
    source_groups      = [data.nsxt_policy_group.mgmt.path]
    action             = "ALLOW"
    logged             = true
    scope              = [data.nsxt_policy_tier1_gateway.t1-internal.path]
  }

  rule {
    display_name       = "Allow DMZ"
    source_groups      = [nsxt_policy_group.dmz.path]
    services           = [nsxt_policy_service.couchdb.path]
    action             = "ALLOW"
    logged             = true
    scope              = [data.nsxt_policy_tier1_gateway.t1-internal.path]
  }


  rule {
    display_name       = "Allow Outbound"
    source_groups      = [nsxt_policy_group.internal.path]
    action             = "ALLOW"
    logged             = true
    scope              = [data.nsxt_policy_tier1_gateway.t1-internal.path]
  }
 
  rule {
    display_name       = "Allow traffic between NSX-ALB SE and Controller"
    source_groups      = [data.nsxt_policy_group.alb-a-ControllerCluster.path, data.nsxt_policy_group.alb-a-ServiceEngineMgmtIPs.path]
    destination_groups = [data.nsxt_policy_group.alb-a-ServiceEngineMgmtIPs.path, data.nsxt_policy_group.alb-a-ControllerCluster.path]
    action             = "ALLOW"
    logged             = false
    scope              = [data.nsxt_policy_tier1_gateway.t1-internal.path]
  }

  rule {
    display_name       = "Allow traffic from NSX-ALB SE to Pool Servers"
    source_groups      = [data.nsxt_policy_group.alb-a-ServiceEngines.path]
    destination_groups = [data.nsxt_policy_group.web.path]
    action             = "ALLOW"
    logged             = false
    scope              = [data.nsxt_policy_tier1_gateway.t1-internal.path]
  }
 rule {
    display_name       = "Block the Rest Inbound"
    action             = "REJECT"
    logged             = true
    scope              = [data.nsxt_policy_tier1_gateway.t1-internal.path]
  }


}
