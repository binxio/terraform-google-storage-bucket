locals {
  owner       = "myself"
  project     = "testapp"
  company     = "mycompany"
  environment = var.environment

  buckets = {
    "functions" = {
      location           = var.location
      versioning_enabled = true
      roles = {
        # Not used atm, so skip this test
        # "roles/storage.objectViewer"       = [format("group:%s@example.com", local.owner)]
        "roles/storage.legacyObjectReader" = [format("serviceAccount:%s", var.sa_reader_email)]
        "roles/storage.legacyBucketOwner"  = [format("serviceAccount:%s", var.sa_owner_email)]
      }
    }
    "processed" = {
      location           = var.location
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
