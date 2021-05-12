output "lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_elb.asg_elb.id
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_elb.asg_elb.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_elb.asg_elb.dns_name
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = aws_elb.asg_elb.zone_id
}

output "lb_sg_id" {
  description = "aws elb securiry group id"
  value       = aws_security_group.elb_sg.id
}
