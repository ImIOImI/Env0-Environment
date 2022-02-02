terraform {
  required_providers {
    env0 = {
      source  = "env0/env0"
      version = "0.0.22"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }

  required_version = "~> 1.0.5"
}

locals {
  data              = var.data
  github-id         = var.github-id
  repo              = var.repo
  revision          = var.revision
  suffix            = var.name-suffix
  terraform-version = var.terraform-version
}

resource "env0_template" "template" {
  for_each               = local.data
  name                   = "${each.key}-${local.suffix}"
  description            = <<EOT
Template for ${each.key} created via Terraform
EOT
  repository             = local.repo
  path                   = each.value["env0-template-root"]
  terraform_version      = local.terraform-version
  revision               = local.revision
  github_installation_id = local.github-id
  type                   = "terraform"

  lifecycle {
    ignore_changes = [description]
  }
}

resource "env0_template_project_assignment" "assignment" {
  for_each    = local.data
  template_id = env0_template.template[each.key].id
  project_id  = each.value["env0-project-id"]
}

resource "env0_environment" "example" {
  for_each    = local.data
  name        = "${each.key}-${local.suffix}"
  project_id  = each.value["env0-project-id"]
  template_id = env0_template.template[each.key].id

  approve_plan_automatically = each.value["env0-require-approval"] == true ? false : true
  auto_deploy_by_custom_glob = each.value["env0-triggers"]
  deploy_on_push             = true
  run_plan_on_pull_requests  = each.value["env0-plan-on-pr"]
  force_destroy              = each.value["env0-disable-destroy"] == true ? false : true
  workspace                  = "default"
}
