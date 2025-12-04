terraform {
  backend "s3" {
    bucket         = "hera-dev-tf-state-628987527285"
    key            = "dev/aws/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hera-dev-tf-lock-628987527285"
    encrypt        = true
  }
}