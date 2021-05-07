module "asg" {
  source              = "../modules/aws-ec2-asg"
  name_prefix         = var.prefix
  image_id            = "ami-00579fbb15b954340"
  instance_type       = "c5.xlarge"
  max_size            = 7
  min_size            = 1
  vpc_id              = var.vpcid
  user_data_base64    = fileexists("script.sh") ? file("script.sh") : null
  vpc_zone_identifier = ["${module.getvpcdetails.private_subnet_ids}"]
  ingress_from_port   = 22
  ingress_to_port     = 22
  ingress_protocol    = "tcp"
  elb_sg_id           = module.elb.lb_sg_id
  key_name            = "ec2_key"
  web_app_iam_role    = module.iam.web_app_iam_role
  vpc_private_cidr    = module.getvpcdetails.subnet_private_cidr_blocks
}

module "getvpcdetails" {
  source = "../modules/get_vpc_details"
  vpc_id = var.vpcid
}

module "elb" {
  source            = "../modules/aws-elb"
  vpc_id            = var.vpcid
  ingress_from_port = 8000
  ingress_to_port   = 8000
  ingress_protocol  = "tcp"
  natgwip_az1       = "51.110.140.122/32"
  natgwip_az2       = "51.108.153.20/32"
  natgwip_az3       = "51.108.170.77/32"
  subnets           = [module.getvpcdetails.subnet_public_cidr_blocks]
}

module "route53" {
  source          = "../modules/aws-route53"
  custom_dns_name = "dev.company.com"
  lb_zone_id      = module.elb.lb_zone_id
  lb_dns_name     = module.elb.lb_dns_name
}

module "iam" {
  source      = "../modules/aws-iam-role"
  name_prefix = var.prefix
}
