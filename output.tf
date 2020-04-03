output "api_endpoint" {
  value = module.heimdall.external_lb_dns_name
}

output "ui_endpoint" {
  value = module.me_you.elb_dns_name
}
