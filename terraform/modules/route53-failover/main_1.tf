resource "aws_route53_health_check" "primary" {
  fqdn = var.primary_alb_dns
  port = 443
  type = "HTTPS"
  resource_path = "/healthz"
  failure_threshold = 3
  request_interval = 10
  enable_sni = true
  tags = { Name="paysecure-primary" }
}
resource "aws_route53_record" "primary_failover" {
  zone_id = var.zone_id
  name = var.record_name
  type = "A"
  set_identifier = "primary"
  failover_routing_policy { type="PRIMARY" }
  health_check_id = aws_route53_health_check.primary.id
  alias { name=var.primary_alb_dns zone_id=var.primary_alb_zone_id evaluate_target_health=true }
}
resource "aws_route53_record" "secondary_failover" {
  zone_id = var.zone_id
  name = var.record_name
  type = "A"
  set_identifier = "secondary"
  failover_routing_policy { type="SECONDARY" }
  alias { name=var.secondary_alb_dns zone_id=var.secondary_alb_zone_id evaluate_target_health=true }
}
variable "zone_id" {}
variable "record_name" { default="api.paysecure.in" }
variable "primary_alb_dns" {}
variable "primary_alb_zone_id" {}
variable "secondary_alb_dns" {}
variable "secondary_alb_zone_id" {}
