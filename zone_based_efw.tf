data "nsxt_policy_tier1_gateway" "t1-internal" {
  display_name = "t1-internal"
}

data "nsxt_policy_group" "mgmt" {
  display_name = "mgmt"
}

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

resource "nsxt_policy_group" "dev" {
  nsx_id       = "dev"
  display_name = "dev"
  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.60.11/32"]
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
    destination_groups = [nsxt_policy_group.dev.path]
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
    display_name       = "Block the Rest Inbound"
    action             = "REJECT"
    logged             = true
    scope              = [data.nsxt_policy_tier1_gateway.t1-internal.path]
  }


}
