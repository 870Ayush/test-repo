###############################################################################
# Binds the account-level user group "terraform-test" to the project-level
# role "terraform-test" and the "All Project Level Resources" resource group
# in the Default Project (org: default, project: default_project).
###############################################################################

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.30.0"
    }
  }
}

provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = var.account_id
  platform_api_key = var.platform_api_key
}

variable "account_id" {
  type        = string
  description = "Harness account identifier."
}

variable "platform_api_key" {
  type        = string
  sensitive   = true
  description = "Harness platform API key (PAT/SAT) allowed to manage role assignments."
}

variable "org_id" {
  type    = string
  default = "default"
}

variable "project_id" {
  type    = string
  default = "default_project"
}

# Account-level user group (identifier; its display name is "terrafrom-test").
variable "user_group_identifier" {
  type    = string
  default = "terrafromtest"
}

# Project-level role named "terraform-test".
variable "role_identifier" {
  type    = string
  default = "terraformtest"
}

# Harness-managed resource group: all resources at project scope.
variable "resource_group_identifier" {
  type    = string
  default = "_all_project_level_resources"
}

# Fails the plan early if the account-level user group does not exist.
data "harness_platform_usergroup" "terraform_test" {
  identifier = var.user_group_identifier
}

resource "harness_platform_role_assignments" "terraform_test" {
  identifier                = "terraformtest_all_project_resources"
  org_id                    = var.org_id
  project_id                = var.project_id
  resource_group_identifier = var.resource_group_identifier
  role_identifier           = var.role_identifier

  principal {
    identifier  = data.harness_platform_usergroup.terraform_test.identifier
    type        = "USER_GROUP"
    scope_level = "account"
  }

  disabled = false
}

output "role_assignment_id" {
  value = harness_platform_role_assignments.terraform_test.id
}
