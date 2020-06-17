locals {
  owner       = "myself"
  environment = "dev"
  project     = "testapp"

  buckets = {
    "functions" = {
    }
    "processed" = {
    }
  }
}

module "buckets" {
  source  = "binxio/storage-bucket/google"
  version = "~> 1.0.0"

  owner       = local.owner
  environment = local.environment
  project     = local.project
  prefix      = "mycomp"

  buckets = local.buckets
}
