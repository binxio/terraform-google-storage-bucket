output "bucket_defaults" {
  description = "The generic defaults used for bucket settings"
  value = {
    location           = "europe-west4"
    storage_class      = "REGIONAL"
    versioning_enabled = true
    bucket_policy_only = true
    lifecycle_rules    = {}
    roles              = null
  }
}

output "map" {
  description = "outputs for all google_storage_buckets created"
  value       = { for key, bucket in google_storage_bucket.map : key => bucket }
}
