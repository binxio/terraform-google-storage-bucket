#######################################################################################################
#
# Terraform does not have a easy way to check if the input parameters are in the correct format.
# On top of that, terraform will sometimes produce a valid plan but then fail during apply.
# To handle these errors beforehad, we're using the 'file' hack to throw errors on known mistakes.
#
#######################################################################################################
locals {
  # Regular expressions
  regex_bucket_name = "(([a-z0-9]|[a-z0-9][a-z0-9\\-]*[a-z0-9])\\.)*([a-z0-9]|[a-z0-9][a-z0-9\\-]*[a-z0-9])" # See https://cloud.google.com/storage/docs/naming-buckets

  # Terraform assertion hack
  assert_head = "\n\n-------------------------- /!\\ ASSERTION FAILED /!\\ --------------------------\n\n"
  assert_foot = "\n\n-------------------------- /!\\ ^^^^^^^^^^^^^^^^ /!\\ --------------------------\n"
  asserts = {
    for bucket, settings in local.buckets : bucket => merge({
      bucketname_too_long = length(settings.bucket_name) > 63 ? file(format("%sbucket [%s]'s generated name is too long:\n%s\n%s > 63 chars!%s", local.assert_head, bucket, settings.bucket_name, length(settings.bucket_name), local.assert_foot)) : "ok"
      bucketname_regex    = length(regexall("^${local.regex_bucket_name}$", settings.bucket_name)) == 0 ? file(format("%sbucket [%s]'s generated name [%s] does not match regex ^%s$%s", local.assert_head, bucket, settings.bucket_name, local.regex_bucket_name, local.assert_foot)) : "ok"
      keytest = {
        for setting in keys(settings) : setting => merge(
          {
            keytest = lookup(local.bucket_defaults, setting, "!TF_SETTINGTEST!") == "!TF_SETTINGTEST!" ? file(format("%sUnknown bucket variable assigned - bucket [%s] defines [%q] -- Please check for typos etc!%s", local.assert_head, bucket, setting, local.assert_foot)) : "ok"
        })
      }
    })
  }
}
