locals {
  company     = "company"
  owner       = "myself"
  environment = "dev"
  project     = "testapp"

  gcp_project = format("%s-%s-%s", local.company, local.environment, local.project)

  buckets = {
    "functions" = {
      roles = {
        "roles/storage.objectViewer"       = [format("group:%s@example.com", local.owner)]
        "roles/storage.legacyObjectReader" = [format("serviceAccount:%s-%s-%s-%s@%s.iam.gserviceaccount.com", local.environment, local.project, "sa1", local.gcp_project)]
        "roles/storage.legacyBucketOwner"  = [format("serviceAccount:%s-%s-%s-%s@%s.iam.gserviceaccount.com", local.environment, local.project, "sa2", local.gcp_project)]
      }
      versioning_enabled = true
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
  version = "~> 1.0.0"

  prefix      = local.company
  owner       = local.owner
  environment = local.environment
  project     = local.project

  buckets = local.buckets
}
