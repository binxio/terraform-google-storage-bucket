#---------------------------------------------------------------------------------------------
# Define our locals for increased readability
#---------------------------------------------------------------------------------------------

locals {
  prefix      = var.prefix
  project     = var.project
  environment = var.environment

  bucket_defaults = merge(var.bucket_defaults, {
    owner       = var.owner,
    bucket_name = null # Invalid name, but make sure the key exists
  })

  labels = {
    "project"     = substr(replace(local.project, "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
    "environment" = substr(replace(local.environment, "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
    "creator"     = "terraform"
  }

  # Merge bucket global default settings with bucket specific settings and generate bucket_name
  # Example generated bucket_name: "mycomp-data-dev-processed"
  buckets = {
    for bucket, settings in var.buckets : bucket => merge(
      local.bucket_defaults,
      settings,
      {
        bucket_name = replace(lower(format("%s-%s-%s-%s", local.prefix, local.project, local.environment, bucket)), " ", "-")
      }
    )
  }
}

#---------------------------------------------------------------------------------------------
# GCP Resources
#---------------------------------------------------------------------------------------------

resource "google_storage_bucket" "map" {
  provider = google-beta

  for_each      = local.buckets
  force_destroy = var.buckets_force_destroy

  name               = each.value.bucket_name
  location           = each.value.location
  storage_class      = each.value.storage_class
  bucket_policy_only = each.value.bucket_policy_only
  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules

    content {
      action {
        type          = lookup(lifecycle_rule.value.action, "type", null)
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }

      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
        created_before        = lookup(lifecycle_rule.value.condition, "created_before", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }

  versioning {
    enabled = each.value.versioning_enabled
  }

  labels = merge(
    local.labels,
    {
      purpose = substr(replace(each.key, "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
      owner   = substr(replace(each.value.owner, "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
    }
  )
}

data "google_iam_policy" "map" {
  for_each = { for bucket, settings in local.buckets : bucket => settings if settings.roles != null }

  dynamic "binding" {
    for_each = each.value.roles

    content {
      role    = binding.key
      members = binding.value
    }
  }
}

resource "google_storage_bucket_iam_policy" "map" {
  for_each = data.google_iam_policy.map

  bucket      = google_storage_bucket.map[each.key].name
  policy_data = each.value.policy_data
}
