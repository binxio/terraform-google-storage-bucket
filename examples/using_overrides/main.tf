locals {
  company     = "company"
  owner       = "myself"
  project     = "demo"
  environment = "dev"

  gcp_project = format("%s-%s-%s", local.company, local.project, local.environment)

  buckets = {
    "functions" = {
      versioning_enabled = true
      roles = {
        "roles/storage.objectViewer" = {
          format("%s@example.com", local.owner) = "group"
        }
        "roles/storage.legacyObjectReader" = {
          format("%s-%s-%s@%s.iam.gserviceaccount.com", local.project, local.environment, "sa1", local.gcp_project) = "serviceAccount"
        }
      }
    }
    "processed" = {
      versioning_enabled = false
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
    }
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

  # Override bucket location defaults for all our buckets at once
  # -------------------------------------------------------------
  # Use the module output to get standard bucket_defaults
  # and merge those with our own vars
  bucket_defaults = merge(
    module.buckets.bucket_defaults,
    {
      location = var.bucket_location
    }
  )
}
