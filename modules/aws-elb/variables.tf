variable "vpc_id" {
  description = "VPC id of the AWS account"
}
variable "ingress_from_port" {
  description = "Ingress Port"
}
variable "ingress_to_port" {
  description = "Ingress Port"
}
variable "ingress_protocol" {
  description = "Ingress Protocol"
}
variable "natgwip_az1" {
  description = "nat gateway az1 ip"
}
variable "natgwip_az2" {
  description = "nat gateway az2 ip"
}
variable "natgwip_az3" {
  description = "nat gateway az3 ip"
}
variable "subnets" {
  description = "A list of subnet cidr blocks."
  type        = list(any)
}
