variable "data" {
  type        = map(any)
  description = "Map of data with triggers (env0-triggers) and root (env0-template-root) injected in"
}

variable "github-id" {
  type        = number
  description = "Env0 id for the Github repo for the template"
}

variable "name-suffix" {
  type        = string
  description = "templates and environment names will have this appended to them like {each.key}-<suffix>"
}

variable "repo" {
  type        = string
  description = "url to the github repo ex: https://github.com/quadpay/quadpay-devops"
}

variable "revision" {
  type        = string
  default     = "master"
  description = "git branch the code resides on"
}

variable "terraform-version" {
  default     = "1.0.5"
  type        = string
  description = <<EOT
  The version of terraform that should run your project. Not to be confused with the version of Terraform 
  that will build the Env0 project/template/environment/variables
  EOT
}
