locals {
  owner       = var.owner
  environment = var.environment
  region      = "global"
  project     = "testapp"

  buckets = {
    "replicate" = {}
    "trigger-assertions for bucket 'cause this name is too long and has invalid chars" = {
      not_existing = "should-fail"
    }
  }
}

module "bucket" {
  source = "../../"

  owner       = local.owner
  environment = local.environment
  project     = local.project
  prefix      = "mycomp"

  buckets = local.buckets
}
