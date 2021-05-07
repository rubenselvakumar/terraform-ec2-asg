resource "aws_route53_record" "elb_dns_record" {
  zone_id = var.lb_zone_id
  name    = var.custom_dns_name
  type    = "CNAME"
  ttl     = "60"
  records = [var.lb_dns_name]
}
