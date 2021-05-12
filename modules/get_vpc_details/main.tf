data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  tags = {
    Subnet = "Private"
  }
}

data "aws_subnet" "private" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}

data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id

  tags = {
    Subnet = "Public"
  }
}

data "aws_subnet" "public" {
  for_each = data.aws_subnet_ids.public.ids
  id       = each.value
}

output "private_subnet_ids" {
  value = data.aws_subnet_ids.private.ids
}

output "public_subnet_ids" {
  value = data.aws_subnet_ids.public.ids
}

output "subnet_private_cidr_blocks" {
  value = [for p in data.aws_subnet.private : p.cidr_block]
}

output "subnet_public_cidr_blocks" {
  value = [for s in data.aws_subnet.public : s.cidr_block]
}
