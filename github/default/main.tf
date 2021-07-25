locals {
  environment           = "default"
  aws_region            = "us-west-2"
}

resource "random_password" "random" {
  length = 28
}

resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
}

# resource "aws_kms_key" "github" {
#   is_enabled = false
# }

module "runners" {
  source  = "philips-labs/github-runner/aws"
  version = "0.15.1"

  aws_region            = local.aws_region
  runners_maximum_count = 10
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnets

  environment = local.environment
  tags = {
    Project = "ProjectX"
  }

  github_app = {
    key_base64     = var.github_app_key_base64
    id             = var.github_app_id
    client_id      = var.github_app_client_id
    client_secret  = var.github_app_client_secret
    webhook_secret = random_password.random.result
  }

  webhook_lambda_zip                = "lambdas-download/webhook.zip"
  runner_binaries_syncer_lambda_zip = "lambdas-download/runner-binaries-syncer.zip"
  runners_lambda_zip                = "lambdas-download/runners.zip"
  enable_organization_runners       = false
  runner_extra_labels               = "default,example"

  # enable access to the runners via SSM
  enable_ssm_on_runners = true

  # Uncommet idle config to have idle runners from 9 to 5 in time zone Amsterdam
  # idle_config = [{
  #   cron      = "* * 9-17 * * *"
  #   timeZone  = "Europe/Amsterdam"
  #   idleCount = 1
  # }]

  # disable KMS and encryption
  # encrypt_secrets = false

  # Let the module manage the service linked role
  # create_service_linked_role_spot = true
}
