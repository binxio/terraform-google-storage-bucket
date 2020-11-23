# Changelog

## v1.1.0 (2020-11-23)

### Features

* logging can now be provided with bucket variables
* retention_period can now be provided with bucket variables
* The `bucket_defaults` output now doesn't use the `bucket_defaults` variable value anymore but defines itself. This way it can be used directly when the module is implemented.
Example usage:

```
module "buckets" {
  source  = "binxio/storage-bucket/google"
  version = "~> 1.1.0"

  prefix      = "company"
  environment = "dev"
  project     = "demo"
  owner       = "myself"

  buckets = {
    "functions" = {
      versioning_enabled = true
	}
	"data" = {}
  }

  # Merge bucket_defaults defined by the module itself with our overrides
  bucket_defaults = merge(
    module.buckets.bucket_defaults,
    {
      location = var.bucket_location
    }
  )
}
```

### Fixes

* Cleaner code with `try` function
* When a capital character was used in any of the variables used for label creation, they would be replaced with "\_". We now convert the variables with lower() first.

## v1.0.0 (2020-04-28)

* Initial release

### Features

* Initial release of this module based on Terraform 0.12
