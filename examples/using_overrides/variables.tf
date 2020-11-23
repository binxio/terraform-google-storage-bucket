variable "sa_owner_email" {
  type        = string
  description = "Service account email address to provide demo owner access for storage bucket"
}
variable "sa_viewer_email" {
  type        = string
  description = "Service account email address to provide demo viewer access for storage bucket"
}
variable "bucket_location" {
  type        = string
  description = "The location to use for our buckets"
}
