<!-- BEGIN_TF_DOCS -->
## Description 
The env0 module uses a 1:1 relationship, so for every environment there will be a corresponding template. This mirrors the way we 
build our code where each environment has it's own folder with it's own terraform code. In fact, Env0 requires that the 
template refers to actual code that we are going to run, so this 1:1 relationship is dictated by our architecture. 

This module consumes an edited map of data generated from the global module via the `data` input. Two keys need to be 
injected in (one for the triggers and one for the path to the template) and the map needs to be filtered to relevant 
contexts. Triggers are required to be in [glob format](https://en.wikipedia.org/wiki/Glob_(programming)). I recommend 
adding an empty path key in the default context in `quadpay-devops/terraform/modules/global/context.tf` then adding keys 
in the relevant contexts like:

```terraform
locals {
  //contexts are to be defined as <country>-<az slug>-<env>
  ctxt = {
    default              = {
      #..
      root-private-link-zones = ""
      #...
    }
    #...
    us-eastus-prd        = {
      #..
      root-private-link-zones = "terraform/environments/production/private-link-zones"
      #..
    }
    #...
  }
}
```

This populates the `local.all` map with everything you need to both find the code Env0 needs to run, and filter the 
environments. You can inject needed keys and filter by doing the following:

```terraform
locals {
  all-private-link-zones = { for context, v in local.all : context =>
  merge(
      v,
      {
        env0-triggers = "+(${lookup(v, "root-private-link-zones", "")}/**)"
      },
      {
        env0-template-root = "${lookup(v, "root-private-link-zones", "")}"
      }
    )
    if length(lookup(v, "root-private-link-zones", "")) > 0
  }
}

module "private-link-zones" {
  source = "./modules/environment"
  providers = {
    env0 = env0
  }

  name-suffix = "private-link-zones"
  data        = local.all-private-link-zones
  github-id  = local.github-id
  repo       = module.global.repo

  terraform-version = "1.1.3"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0.5 |
| <a name="requirement_env0"></a> [env0](#requirement\_env0) | 0.0.22 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_env0"></a> [env0](#provider\_env0) | 0.0.22 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [env0_environment.example](https://registry.terraform.io/providers/env0/env0/0.0.22/docs/resources/environment) | resource |
| [env0_template.template](https://registry.terraform.io/providers/env0/env0/0.0.22/docs/resources/template) | resource |
| [env0_template_project_assignment.assignment](https://registry.terraform.io/providers/env0/env0/0.0.22/docs/resources/template_project_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data"></a> [data](#input\_data) | Map of data with triggers (env0-triggers) and root (env0-template-root) injected in | `map(any)` | n/a | yes |
| <a name="input_github-id"></a> [github-id](#input\_github-id) | Env0 id for the Github repo for the template | `number` | n/a | yes |
| <a name="input_name-suffix"></a> [name-suffix](#input\_name-suffix) | templates and environment names will have this appended to them like {each.key}-<suffix> | `string` | n/a | yes |
| <a name="input_repo"></a> [repo](#input\_repo) | url to the github repo ex: https://github.com/quadpay/quadpay-devops | `string` | n/a | yes |
| <a name="input_revision"></a> [revision](#input\_revision) | git branch the code resides on | `string` | `"master"` | no |
| <a name="input_terraform-version"></a> [terraform-version](#input\_terraform-version) | The version of terraform that should run your project. Not to be confused with the version of Terraform <br>  that will build the Env0 project/template/environment/variables | `string` | `"1.0.5"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_environments"></a> [environments](#output\_environments) | n/a |
| <a name="output_templates"></a> [templates](#output\_templates) | n/a |
<!-- END_TF_DOCS -->