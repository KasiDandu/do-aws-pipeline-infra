terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket       = "kasidandu-tf-state-ACCOUNT_ID" # TODO: replace ACCOUNT_ID after bootstrap
    key          = "pipelines/preprod/ppi-triage/process.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-west-2"
}

locals {
  glue_cfg    = yamldecode(file("${path.module}/glue_job_config.yaml"))
  lambda_file = "${path.module}/config.yaml"
}

module "pipeline" {
  source = "git::https://github.com/KasiDandu/do-aws-tf-process-pipeline-bp.git?ref=v0.0.1"

  environment       = "preprod"
  data_pipeline     = "ppi-triage"
  glue_job_settings = local.glue_cfg.glue_job_settings
  queue_settings    = try(local.glue_cfg.queue_settings, {})
  lambda_settings   = fileexists(local.lambda_file) ? yamldecode(file(local.lambda_file)).lambda_settings : null
  s3_settings       = { force_destroy = true } # practice only
}

output "pipeline" {
  value = module.pipeline
}
