provider "aws" {
  access_key = "xxxxxxxxxxxxx"
  secret_key = "xxxxxxxxxxxxx"

  region  = local.aws_region
  version = "3.20"
}
