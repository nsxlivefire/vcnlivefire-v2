data "nsxt_policy_tier0_gateway" "t0-stretched" {
  provider = nsxt.global_manager
  display_name = "t0-stretched"
}

# Create t1-stretched DR-ONLY logical-router and connect to active-active t0-stretched Logical router 
resource "nsxt_policy_tier1_gateway" "t1-stretched" {
  provider = nsxt.global_manager
  description               = "Tier-1 Stretched"
  display_name              = "t1-stretched"
  default_rule_logging      = "false"
  enable_firewall           = "false"
  enable_standby_relocation = "false"
  tier0_path                = data.nsxt_policy_tier0_gateway.t0-stretched.path
  route_advertisement_types = ["TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"
  }

# Create ov-web-stretched and ov-db-stretched segments that connects to t1-stretched

resource "nsxt_policy_segment" "ov-db-stretched" {
  provider = nsxt.global_manager
  display_name        = "ov-db-stretched"
  description         = "Strectched DB Segment"
  connectivity_path   = nsxt_policy_tier1_gateway.t1-stretched.path
  subnet {
   cidr        = "172.16.20.1/24"
         }
  tag {
    scope = "zone"
    tag   = "internal"
      }
  }
resource "nsxt_policy_segment" "ov-web-stretched" {
  provider = nsxt.global_manager
  display_name        = "ov-web-stretched"
  description         = "Strectched Web Segment"
  connectivity_path   = nsxt_policy_tier1_gateway.t1-stretched.path
  subnet {
   cidr        = "172.16.10.1/24"
         }
  tag {
    scope = "zone"
    tag   = "internal"
      }
  }

#Create Global Group for 2-tier webapp for grouing Web and DB VMs in seperate groups

resource "nsxt_policy_group" "g-web-stretched" {
  provider = nsxt.global_manager
  display_name = "g-web-stretched"
  description  = "Stretched Global web group"
  nsx_id = "g-web-stretched"
  tag {
      scope = "webapp"
      tag = "web"
       }


  criteria {
   condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      value       = "webapp|web"
     }
           }
}
resource "nsxt_policy_group" "g-db-stretched" {
  provider = nsxt.global_manager
  display_name = "g-db-stretched"
  description  = "Stretched Global db group"
  nsx_id = "g-db-stretched"
  tag {
      scope = "webapp"
      tag = "db"
       }


  criteria {
   condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      value       = "webapp|db"
     }
           }
}

# Create 2-Tier webapp Global DFW rule

data "nsxt_policy_service" "HTTPS" {
  provider = nsxt.global_manager
  display_name = "HTTPS"
}
data "nsxt_policy_service" "ICMPv4-ALL"{
  provider = nsxt.global_manager
  display_name = "ICMPv4-ALL"
}
data "nsxt_policy_service" "MySQL"{
  provider = nsxt.global_manager
  display_name = "MySQL"
}

resource "nsxt_policy_security_policy" "stretched-dfw" {
  provider = nsxt.global_manager
  display_name = "WebApp Stretched Policy"
  description  = "2-tier webapp Security Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = false
  scope        = [nsxt_policy_group.g-web-stretched.path, nsxt_policy_group.g-db-stretched.path ]

  rule {
    display_name       = "Allow any to web"
    action             = "ALLOW"
    services           = [data.nsxt_policy_service.HTTPS.path, data.nsxt_policy_service.ICMPv4-ALL.path ]
    logged             = true
    destination_groups = [nsxt_policy_group.g-web-stretched.path]
       }

  rule {
    display_name       = "Allow web to db"
    action             = "ALLOW"
    source_groups      = [nsxt_policy_group.g-web-stretched.path]
    services           = [data.nsxt_policy_service.MySQL.path]
    destination_groups = [nsxt_policy_group.g-db-stretched.path]
    logged             = true
       }

  rule {
    display_name       = "Allow webapp out"
    action             = "ALLOW"
    source_groups      = [nsxt_policy_group.g-web-stretched.path,nsxt_policy_group.g-db-stretched.path]
    logged             = true
       }

  rule {
    display_name     = "Deny any"
    action           = "DROP"
       }
}
