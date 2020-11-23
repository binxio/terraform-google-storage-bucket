locals {
  owner       = "myself"
  project     = "testapp"
  company     = "mycomp"
  environment = var.environment

  default_overrides = {
    location = var.location
  }

  buckets = {
    "functions" = {
      versioning_enabled = true
      roles = {
        "roles/storage.legacyObjectReader" = { format("%s", var.sa_reader_email) = "serviceAccount" }
        "roles/storage.legacyBucketOwner"  = { format("%s", var.sa_owner_email) = "serviceAccount" }
      }
      logging = {
        log_bucket = replace(lower(format("%s-%s-%s-logging", local.company, local.project, local.environment)), " ", "-")
      }
    }
    "processed" = {
      versioning_enabled = false
      retention_policy = {
        is_locked        = true
        retention_period = 1200
      }
      lifecycle_rules = {
        "delete rule" = {
          action = {
            type = "Delete"
          }
          condition = {
            age        = 30    # after 30 days
            with_state = "ANY" # both LIVE as well as ARCHIVED files
          }
        }
      }
      labels = {
        "label_key" = "label_value"
      }
    }
  }
}

module "bucket" {
  source = "../../"

  owner       = local.owner
  environment = local.environment
  project     = local.project
  prefix      = local.company

  buckets         = local.buckets
  bucket_defaults = merge(module.bucket.bucket_defaults, local.default_overrides)
}

output "map" {
  value = module.bucket.map
}
