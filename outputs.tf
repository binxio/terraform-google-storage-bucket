output "bucket_defaults" {
  description = "The generic defaults used for bucket settings"
  value       = local.module_bucket_defaults
}

output "map" {
  description = "outputs for all google_storage_buckets created"
  value       = google_storage_bucket.map
}
