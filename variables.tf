#------------------------------------------------------------------------------------------------------------------------
# 
# Generic variables
#
#------------------------------------------------------------------------------------------------------------------------
variable "owner" {
  description = "Owner of the resource. This variable is used to set the 'owner' label. Will be used as default for each bucket, but can be overridden using the bucket settings."
  type        = string
}

variable "prefix" {
  description = "Company naming prefix, ensures uniqueness of bucket names"
  type        = string
}

variable "project" {
  description = "Company project name."
  type        = string
}

variable "environment" {
  description = "Company environment for which the resources are created (e.g. dev, tst, acc, prd, all)."
  type        = string
}

variable "gcp_project" {
  description = "GCP Project ID override - this is normally not needed and should only be used in tf-projects."
  type        = string
  default     = null
}

#------------------------------------------------------------------------------------------------------------------------
#
# Bucket variables
#
#------------------------------------------------------------------------------------------------------------------------

variable "buckets_force_destroy" {
  description = "When set to true, allows TFE to remove buckets that still contain objects"
  type        = bool
  default     = false
}

variable "buckets" {
  description = <<EOF
Map of buckets to be created. The key will be used for the bucket name so it should describe the bucket purpose. The value can be a map with the following keys to override default settings:
  * owner
  * location
  * storage_class
  * versioning_enabled
	* retention_policy
  * uniform_bucket_level_access
  * lifecycle_rules
	* logging
  * roles
  * labels
EOF
  type        = any
}

variable "bucket_defaults" {
  description = "Default settings to be used for your buckets so you don't need to provide them for each bucket separately."
  type = object({
    location                    = string
    storage_class               = string
    versioning_enabled          = bool
    uniform_bucket_level_access = bool
    retention_policy = object({
      is_locked        = bool
      retention_period = number
    })
    lifecycle_rules = map(object({
      action = map(string)
      condition = object({
        age                   = number
        with_state            = string
        created_before        = string
        matches_storage_class = list(string)
        num_newer_versions    = number
      })
    }))
    logging = object({
      log_bucket        = string
      log_object_prefix = string
    })
    roles  = map(map(string))
    labels = map(string)
    owner  = string
  })
  default = null
}
