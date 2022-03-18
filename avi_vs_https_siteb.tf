## provider setup
terraform {
	required_providers {
		avi = {
			source  = "vmware/avi"
			version = "21.1.3"
		}
	}
}
provider "avi" {
	avi_controller		= var.avi_controller
	avi_username		= var.avi_username
	avi_password		= var.avi_password
	avi_version		= var.avi_version
	avi_tenant		= "admin"
}

## avi data objects
data "avi_tenant" "admin" {
	name	= "admin"
}
data "avi_cloud" "nsxt_cloud" {
	name	= var.cloud_name
}
data "avi_serviceenginegroup" "serviceenginegroup" {
	name	= var.serviceenginegroup
}
data "avi_applicationprofile" "applicationprofile" {
	name	= var.applicationprofile
}
data "avi_networkprofile" "networkprofile" {
	name	= var.networkprofile
}
data "avi_vrfcontext" "t1-internal" {
	cloud_ref = data.avi_cloud.nsxt_cloud.id
}
data "avi_sslkeyandcertificate" "ssl_cert" {
        name      = var.ssl_cert
}
data "avi_sslprofile" "ssl_profile" {
        name      = var.ssl_profile
}
data "avi_healthmonitor" "healthmonitor" {
        name      = var.healthmonitor
}

## create the avi vip
resource "avi_vsvip" "vsvip" {
	name		= "${var.vs_name}-vip"
	tenant_ref	= data.avi_tenant.admin.id
	cloud_ref	= data.avi_cloud.nsxt_cloud.id
	tier1_lr        = var.nsxt_cloud_lr1

	# static vip IP address
	vip {
		vip_id = "0"
		ip_address {
			type = "V4"
			addr = var.vs_address
		}
	}
}

resource "avi_pool" "lb_pool" {
        name = var.pool_name
        default_server_port = var.pool_default_server_port
        lb_algorithm = var.lb_algorithm
        tier1_lr = var.nsxt_cloud_lr1
        ssl_profile_ref = data.avi_sslprofile.ssl_profile.id
        servers {
                ip {
                        type = "V4"
                        addr = var.server1_ip
                   }
                port = var.server1_port
                }
        servers {
                ip {
                        type = "V4"
                        addr = var.server2_ip
                   }
                port = var.server2_port
                }
        cloud_ref = data.avi_cloud.nsxt_cloud.id
        tenant_ref = data.avi_tenant.admin.id
        health_monitor_refs = [data.avi_healthmonitor.healthmonitor.id]
}

resource "avi_virtualservice" "https_vs" {
	name			= var.vs_name
	tenant_ref		= data.avi_tenant.admin.id
	cloud_ref		= data.avi_cloud.nsxt_cloud.id
	vsvip_ref		= avi_vsvip.vsvip.id
	application_profile_ref	= data.avi_applicationprofile.applicationprofile.id
	network_profile_ref	= data.avi_networkprofile.networkprofile.id
	se_group_ref		= data.avi_serviceenginegroup.serviceenginegroup.id
        pool_ref                = avi_pool.lb_pool.id
        ssl_key_and_certificate_refs  = [data.avi_sslkeyandcertificate.ssl_cert.id]
        ssl_profile_ref               = data.avi_sslprofile.ssl_profile.id
        services {
                 port           = 443
                 enable_ssl     = true
        }
}
