locals {
  company     = "company"
  owner       = "myself"
  project     = "demo"
  environment = "dev"

  buckets = {
    "functions" = {}
    "processed" = {}
  }
}

module "buckets" {
  source  = "binxio/storage-bucket/google"
  version = "~> 1.1.0"

  prefix      = local.company
  owner       = local.owner
  project     = local.project
  environment = local.environment

  buckets = local.buckets
}
