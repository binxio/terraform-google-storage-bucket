locals {
  owner       = "myself"
  project     = "testapp"
  environment = var.environment

  buckets = {
    "functions" = {
      location = var.location
    }
    "processed" = {
      location = var.location
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

output "map" {
  value = module.bucket.map
}
