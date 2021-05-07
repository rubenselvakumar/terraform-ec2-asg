#------------------------------------------------------------------------------
# Misc
#------------------------------------------------------------------------------
variable "name_prefix" {
  description = "Name prefix for resources on AWS"
}
variable "vpc_id" {
  description = "VPC id of the AWS account"
}
variable "elb_sg_id" {
  description = "aws elb security group id"
}
variable "web_app_iam_role" {
  description = "web app instance iam role"
}
variable "ingress_from_port" {
  description = "from port"
}
variable "ingress_to_port" {
  description = "to port"
}
variable "ingress_protocol" {
  description = "protocol"
}
variable "vpc_private_cidr" {
  description = "vpc private cidr blocks"
}
#------------------------------------------------------------------------------
# AWS EC2 LAUNCH CONFIGURATION
#------------------------------------------------------------------------------
variable "image_id" {
  description = "The EC2 image ID to launch."
}
variable "instance_type" {
  description = "The size of instance to launch."
}
variable "key_name" {
  description = "aws_security_group"
}
variable "security_groups" {
  description = "(Optional) A list of associated security group IDS."
  type        = list(any)
  default     = []
}
variable "user_data_base64" {
  description = "(Optional) Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption."
  default     = ""
}
variable "enable_monitoring" {
  description = "(Optional) Enables/disables detailed monitoring. This is enabled by default."
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# AWS EC2 AUTO SCALING GROUP
#------------------------------------------------------------------------------
variable "max_size" {
  description = "The maximum size of the auto scale group."
  type        = number
}
variable "min_size" {
  description = "The minimum size of the auto scale group. (See also Waiting for Capacity.)"
  type        = number
}
variable "health_check_type" {
  description = "(Optional) \"EC2\" or \"ELB\". Controls how health checking is done."
  default     = "EC2"
}
variable "desired_capacity" {
  description = "(Optional) The number of Amazon EC2 instances that should be running in the group. (See also Waiting for Capacity.)"
  type        = number
  default     = 1
}
variable "load_balancers" {
  description = "(Optional) A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead."
  type        = list(any)
  default     = []
}
variable "vpc_zone_identifier" {
  description = "(Optional) A list of subnet IDs to launch resources in."
  type        = list(any)
}
variable "termination_policies" {
  description = "(Optional) A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default."
  type        = list(any)
  default     = ["Default"]
}
variable "min_elb_capacity" {
  description = "(Optional) Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes. (See also Waiting for Capacity.)"
  type        = number
  default     = 0
}
variable "wait_for_elb_capacity" {
  description = "(Optional) Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations. (Takes precedence over min_elb_capacity behavior.) (See also Waiting for Capacity.)"
  type        = number
  default     = 1
}
