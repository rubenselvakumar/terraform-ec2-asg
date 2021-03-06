terraform {
  backend "s3" {
    bucket         = "dev-terraform-lock-s3"
    key            = "terraform.tfstate"
    encrypt        = "true"
    kms_key_id     = "arn:aws:kms:eu-west-1:99999999999:alias/dev-terraform-lock-key"
    region         = "eu-west-1"
    dynamodb_table = "dev-terraform-lock-table"
  }
  required_version = ">= 0.13"
}
