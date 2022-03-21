variable "avi_username" {
  type    = string
  default = "admin"
}
variable "avi_password" {
  type    = string
  default = "VMware1!"
}
variable "avi_controller" {
  type    = string
  default = "avi-01a.corp.local"
}
variable "avi_version" {
  type    = string
  default = "21.1.3"
}
variable "cloud_name" {
  type    = string
  default = "nsxmgr-01b"
}
variable "vs_name" {
  type    = string
  default = "webapp-vs-siteb"
}
variable "pool_name" {
  type    = string
  default = "webapp-vs-siteb-pool"
}
variable "lb_algorithm" {
  type    = string
  default = "LB_ALGORITHM_ROUND_ROBIN"
}
variable "server1_ip" {
  type    = string
  default = "172.16.10.11"
}
variable "server2_ip" {
  type    = string
  default = "172.16.10.12"
}
variable "server1_port" {
  type    = number
  default = 443
}
variable "server2_port" {
  type    = number
  default = 443
}
variable "vs_address" {
  type    = string
  default = "172.26.100.10"
}
variable "nsxt_cloud_lr1" {
  type    = string
  default = "t1-internal"
}
variable "vs_port" {
  type    = number
  default = "443"
}
variable "ssl_profile" {
  type    = string
  default = "System-Standard"
}
variable "healthmonitor" {
  type    = string
  default = "System-HTTPS"
}
variable "pool_default_server_port" {
  type    = number
  default = "443"
}
variable "serviceenginegroup" {
  type    = string
  default = "Default-Group"
}
variable "applicationprofile" {
  type    = string
  default = "System-Secure-HTTP"
}
variable "networkprofile" {
  type    = string
  default = "System-TCP-Proxy"
}
variable "ssl_cert" {
  type    = string
  default = "webapp.corp.local"
}
