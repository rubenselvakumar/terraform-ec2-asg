module "getvpcdetails" {
  source = "../modules/get_vpc_details"
  vpc_id = var.vpcid
}

module "elb" {
  source            = "../modules/aws-elb"
  vpc_id            = var.vpcid
  ingress_from_port = 80
  ingress_to_port   = 80
  ingress_port_elb  = 8080
  ingress_protocol  = "tcp"
  natgwip_az1       = "54.170.17.7/32"
  natgwip_az2       = "54.73.219.9/32"
  natgwip_az3       = "52.210.107.170/32"
  subnets           = module.getvpcdetails.public_subnet_ids
}

#module "route53" {
#  source          = "../modules/aws-route53"
#  custom_dns_name = "webapp"
#  lb_zone_id      = module.elb.lb_zone_id
#  lb_dns_name     = module.elb.lb_dns_name
#}

module "asg" {
  source              = "../modules/aws-ec2-asg"
  name_prefix         = var.prefix
  image_id            = "ami-063d4ab14480ac177"
  instance_type       = "c5.xlarge"
  max_size            = 7
  min_size            = 1
  vpc_id              = var.vpcid
  user_data_base64    = fileexists("../modules/aws-ec2-asg/script.sh") ? filebase64("../modules/aws-ec2-asg/script.sh") : null
  load_balancers      = [module.elb.lb_id]
  vpc_zone_identifier = module.getvpcdetails.private_subnet_ids
  ingress_from_port   = 22
  ingress_to_port     = 22
  ingress_port_elb    = 8080
  ingress_port_ec2    = 80
  ingress_protocol    = "tcp"
  elb_sg_id           = module.elb.lb_sg_id
  key_name            = "ec2_key"
  web_app_iam_role    = module.iam.web_app_iam_role
  vpc_private_cidr    = module.getvpcdetails.subnet_private_cidr_blocks
  vpc_public_cidr     = module.getvpcdetails.subnet_public_cidr_blocks
}

module "iam" {
  source      = "../modules/aws-iam-role"
  name_prefix = var.prefix
}
