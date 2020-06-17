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
  description = "Company Project name"
  type        = string
}

variable "environment" {
  description = "Company environment for which the resources are created (e.g. dev, tst, acc, prd, all)."
  type        = string
}

#------------------------------------------------------------------------------------------------------------------------
#
# Bucket variables
#
#------------------------------------------------------------------------------------------------------------------------

variable "buckets_depend_on" {
  description = "Optional list of resources that need to be created before our bucket creation"
  type        = any
  default     = []
}

variable "buckets_force_destroy" {
  description = "When set to true, allows TFE to remove buckets that still contain objects"
  type        = bool
  default     = false
}

variable "buckets" {
  description = "Map of buckets to be created. The key will be used for the bucket name so it should describe the bucket purpose. The value can be a map with the following keys to override default settings; location, storage_class, owner_email, versioning_enabled, bucket_policy_only."
  type        = any
}

variable "bucket_defaults" {
  description = "Default settings to be used for your buckets so you don't need to provide them for each bucket separately."
  type = object({
    location           = string
    storage_class      = string
    versioning_enabled = bool
    bucket_policy_only = bool
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
    roles = map(list(string))
  })
  default = {
    location           = "europe-west4"
    storage_class      = "REGIONAL"
    versioning_enabled = true
    bucket_policy_only = true
    lifecycle_rules    = {}
    roles              = null
  }
}
