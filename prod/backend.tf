terraform {
  backend "s3" {
    bucket         = "prod-terraform-lock-s3"
    key            = "terraform.tfstate"
    encrypt        = "true"
    kms_key_id     = "arn:aws:kms:eu-west-1:777777777777:alias/prod-terraform-lock-key"
    region         = "eu-west-1"
    dynamodb_table = "prod-terraform-lock-table"
  }
  required_version = ">= 0.13"
}
