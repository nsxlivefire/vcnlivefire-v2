## avi data objects
data "avi_applicationprofile" "system-dns" {
	name	= "System-DNS"
}
data "avi_networkprofile" "system-udp-per-pkt" {
	name	= "System-UDP-Per-Pkt"
}

## create the avi dns vip
resource "avi_vsvip" "dnsvsvip" {
	name		= "${var.dns_vs_name}-vip"
	tenant_ref	= data.avi_tenant.admin.id
	cloud_ref	= data.avi_cloud.nsxt_cloud.id
	tier1_lr        = var.nsxt_cloud_lr1

	# static vip IP address
	vip {
		vip_id = "0"
		ip_address {
			type = "V4"
			addr = var.dns_vs_address
		}
	}
}

resource "avi_virtualservice" "dns_vs" {
	name			= var.dns_vs_name
	tenant_ref		= data.avi_tenant.admin.id
	cloud_ref		= data.avi_cloud.nsxt_cloud.id
	vsvip_ref		= avi_vsvip.dnsvsvip.id
	application_profile_ref	= data.avi_applicationprofile.system-dns.id
	network_profile_ref	= data.avi_networkprofile.system-udp-per-pkt.id
	se_group_ref		= data.avi_serviceenginegroup.serviceenginegroup.id
        services {
                 port           = 53
        }
        enabled			= true
}
