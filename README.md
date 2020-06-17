
# Module `terraform-google-storage-bucket`

Provider Requirements:
* **google:** (any version)
* **google-beta:** (any version)

## Input Variables
* `bucket_defaults` (default `{"bucket_policy_only":true,"lifecycle_rules":{},"location":"europe-west4","roles":null,"storage_class":"REGIONAL","versioning_enabled":true}`): Default settings to be used for your buckets so you don't need to provide them for each bucket separately.
* `buckets` (required): Map of buckets to be created. The key will be used for the bucket name so it should describe the bucket purpose. The value can be a map with the following keys to override default settings; location, storage_class, owner_email, versioning_enabled, bucket_policy_only.
* `buckets_depend_on` (required): Optional list of resources that need to be created before our bucket creation
* `buckets_force_destroy` (required): When set to true, allows TFE to remove buckets that still contain objects
* `environment` (required): Company environment for which the resources are created (e.g. dev, tst, acc, prd, all).
* `owner` (required): Owner of the resource. This variable is used to set the 'owner' label. Will be used as default for each bucket, but can be overridden using the bucket settings.
* `prefix` (required): Company naming prefix, ensures uniqueness of bucket names
* `project` (required): Company Project name

## Output Values
* `bucket_defaults`: The generic defaults used for bucket settings
* `map`: outputs for all google_storage_buckets created

## Managed Resources
* `google_storage_bucket.map` from `google-beta`
* `google_storage_bucket_iam_policy.map` from `google`

## Data Resources
* `data.google_iam_policy.map` from `google`

## Creating a new release
After adding your changed and committing the code to GIT, you will need to add a new tag.
```
git tag vx.x.x
git push --tag
```
If your changes might be breaking current implementations of this module, make sure to bump the major version up by 1.

If you want to see which tags are already there, you can use the following command:
```
git tag --list
```
Testing
=======
This module comes with [terratest](https://github.com/gruntwork-io/terratest) scripts for both unit testing and integration testing.
A Makefile is provided to run the tests using docker, but you can also run the tests directly on your machine if you have terratest installed.

### Run with make
Make sure to set GOOGLE_CLOUD_PROJECT to the right project and GOOGLE_CREDENTIALS to the right credentials json file
You can now run the tests with docker:
```
make test
```

### Run locally
From the module directory, run:
```
cd test && TF_VAR_owner=$(id -nu) go test
```
