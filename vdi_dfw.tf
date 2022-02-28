resource "nsxt_policy_group" "ex-employees" {
  display_name = "ex-employees"

  extended_criteria {
    identity_group {
      distinguished_name             = "CN=EXECS,CN=Users,DC=corp,DC=local"
      domain_base_distinguished_name = "dc=corp,dc=local"
    }
  }
}

data "nsxt_policy_service" "http" {
  display_name = "HTTP"
}

data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}

data "nsxt_policy_group" "lb" {
  display_name = "lb"
}

data "nsxt_policy_group" "web" {
  display_name = "web"
}

resource "nsxt_policy_security_policy" "idfw" {
  display_name = "idfw"
  description  = "Control VDI traffic"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true

  rule {
    display_name       = "deny rule"
    source_groups      = [nsxt_policy_group.ex-employees.path]
    action             = "DROP"
    logged             = true
	services           = [data.nsxt_policy_service.http.path, data.nsxt_policy_service.https.path]
    log_label          = "ex-employees"
	scope              = [data.nsxt_policy_group.web.path,data.nsxt_policy_group.lb.path]
  }

  rule {
    display_name       = "permit rule"
    action             = "ALLOW"
    logged             = true
    services           = [data.nsxt_policy_service.http.path, data.nsxt_policy_service.https.path]
	scope              = [data.nsxt_policy_group.web.path,data.nsxt_policy_group.lb.path]
  }

}

