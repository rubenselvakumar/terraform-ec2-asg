#------------------------------------------------------------------------------
# ec2 Security Group
#------------------------------------------------------------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "ec2 security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "ingress details"
    from_port   = var.ingress_from_port
    to_port     = var.ingress_to_port
    protocol    = var.ingress_protocol
    cidr_blocks = [var.vpc_private_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Ec2 Security Group"
  }
}

#------------------------------------------------------------------------------
# Security group Rule to allow LB to send/receive requests from ec2 instances
#------------------------------------------------------------------------------
resource "aws_security_group_rule" "elbtoec2" {
  type                     = "ingress"
  from_port                = var.ingress_from_port
  to_port                  = var.ingress_to_port
  protocol                 = var.ingress_protocol
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = var.elb_sg_id
}
#------------------------------------------------------------------------------
# Launch Configuration
#------------------------------------------------------------------------------
resource "aws_launch_configuration" "lc" {
  name                 = "${var.name_prefix}_lc"
  image_id             = var.image_id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.webapp_instance_profile.arn
  key_name             = var.key_name
  security_groups      = ["${aws_security_group.ec2_sg.id}"]
  user_data_base64     = var.user_data_base64
}

#------------------------------------------------------------------------------
# Auto Scaling Group
#------------------------------------------------------------------------------
resource "aws_autoscaling_group" "asg" {
  depends_on            = [aws_launch_configuration.lc]
  name                  = "${var.name_prefix}_asg"
  max_size              = var.max_size
  min_size              = var.min_size
  launch_configuration  = aws_launch_configuration.lc.name
  desired_capacity      = var.desired_capacity
  load_balancers        = var.load_balancers
  vpc_zone_identifier   = var.vpc_zone_identifier
  termination_policies  = var.termination_policies
  min_elb_capacity      = var.min_elb_capacity
  wait_for_elb_capacity = var.wait_for_elb_capacity
  tags = [
    {
      key                 = "Name"
      value               = "${var.name_prefix}_asg"
      propagate_at_launch = true
    },
  ]
}

#------------------------------------------------------------------------------
# AUTOSCALING POLICIES
#------------------------------------------------------------------------------
# Scaling UP - CPU High
resource "aws_autoscaling_policy" "cpu_high" {
  name                   = "${var.name_prefix}-cpu-high"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "1"
  cooldown               = "300"
}
# Scaling DOWN - CPU Low
resource "aws_autoscaling_policy" "cpu_low" {
  name                   = "${var.name_prefix}-cpu-high"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "-1"
  cooldown               = "300"
}

#------------------------------------------------------------------------------
# CLOUDWATCH METRIC ALARMS
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "${var.name_prefix}-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.cpu_high.arn}"]
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
  }
}
resource "aws_cloudwatch_metric_alarm" "cpu_low_alarm" {
  alarm_name          = "${var.name_prefix}-cpu-low-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.cpu_low.arn}"]
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
  }
}

#------------------------------------------------------------------------------
# web app instance profile
#------------------------------------------------------------------------------
resource "aws_iam_instance_profile" "webapp_instance_profile" {
  name = "webapp_instance_profile"
  role = var.web_app_iam_role
}
