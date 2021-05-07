resource "aws_security_group" "elb_sg" {
  name        = "aws-elb-sg"
  description = "security group for web app elb"
  vpc_id      = var.vpc_id

  ingress {
    description = "NAT Gateway"
    from_port   = var.ingress_from_port
    to_port     = var.ingress_to_port
    protocol    = var.ingress_protocol
    cidr_blocks = [var.natgwip_az1, var.natgwip_az2, var.natgwip_az3]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "elb Security Group"
  }
}

resource "aws_elb" "asg_elb" {
  name                        = "web-app-elb"
  subnets                     = var.subnets
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 60
  security_groups             = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 8000
    instance_protocol = "tcp"
    lb_port           = 8000
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    target              = "TCP:8000"
    interval            = 30
  }

  tags = {
    Name = "web-app-elb"
  }
}
