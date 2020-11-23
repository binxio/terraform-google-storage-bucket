#---------------------------------------------------------------------------------------------
# Define our locals for increased readability
#---------------------------------------------------------------------------------------------

locals {
  prefix      = var.prefix
  project     = var.project
  environment = var.environment

  gcp_project = (var.gcp_project == null ? null : (length(var.gcp_project) > 0 ? var.gcp_project : null))

  # Startpoint for our bucket defaults
  module_bucket_defaults = {
    location                    = "europe-west4"
    storage_class               = "REGIONAL"
    versioning_enabled          = true
    retention_policy            = null
    uniform_bucket_level_access = true
    lifecycle_rules             = {}
    logging                     = null
    roles                       = null
    labels                      = {}
    owner                       = var.owner
  }

  # Merge module defaults with the user provided defaults
  bucket_defaults   = var.bucket_defaults == null ? local.module_bucket_defaults : merge(local.module_bucket_defaults, var.bucket_defaults)
  buckets_depend_on = var.buckets_depend_on

  labels = {
    "project" = substr(replace(lower(local.project), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
    "env"     = substr(replace(lower(local.environment), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
    "creator" = "terraform"
  }

  # Merge bucket global default settings with bucket specific settings and generate bucket_name
  # Example generated bucket_name: "mycomp-data-dev-processed"
  buckets = {
    for bucket, settings in var.buckets : bucket => merge(
      local.bucket_defaults,
      settings,
      {
        bucket_name = replace(lower(format("%s-%s-%s-%s", local.prefix, local.project, local.environment, bucket)), " ", "-")
        roles       = { for role, members in try(settings.roles, {}) : role => [for member, type in members : format("%s:%s", type, member)] }
      }
    )
  }
}

#---------------------------------------------------------------------------------------------
# GCP Resources
#---------------------------------------------------------------------------------------------

resource "google_storage_bucket" "map" {
  provider = google-beta
  project  = local.gcp_project

  for_each      = local.buckets
  force_destroy = var.buckets_force_destroy

  name                        = each.value.bucket_name
  location                    = each.value.location
  storage_class               = each.value.storage_class
  uniform_bucket_level_access = each.value.uniform_bucket_level_access

  dynamic "logging" {
    for_each = (each.value.logging == null ? {} : { logging = each.value.logging })

    content {
      log_bucket        = logging.value.log_bucket
      log_object_prefix = try(logging.value.log_object_prefix, null)
    }
  }

  dynamic "retention_policy" {
    for_each = (each.value.retention_policy == null ? {} : { policy = each.value.retention_policy })

    content {
      is_locked        = try(retention_policy.value.is_locked, null)
      retention_period = try(retention_policy.value.retention_period, null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules

    content {
      action {
        type          = try(lifecycle_rule.value.action.type, null)
        storage_class = try(lifecycle_rule.value.action.storage_class, null)
      }

      condition {
        age                   = try(lifecycle_rule.value.condition.age, null)
        with_state            = try(lifecycle_rule.value.condition.with_state, null)
        created_before        = try(lifecycle_rule.value.condition.created_before, null)
        matches_storage_class = try(lifecycle_rule.value.condition.matches_storage_class, null)
        num_newer_versions    = try(lifecycle_rule.value.condition.num_newer_versions, null)
      }
    }
  }

  versioning {
    enabled = each.value.versioning_enabled
  }

  labels = merge(
    local.labels,
    {
      purpose = substr(replace(lower(each.key), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
      owner   = substr(replace(lower(each.value.owner), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
    },
    each.value.labels
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

