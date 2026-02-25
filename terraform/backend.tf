terraform {
  backend "s3" {
    bucket = "my-aws-terraform-state-bucket-amit-123"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}