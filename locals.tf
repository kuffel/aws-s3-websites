locals {

  sites = flatten([
    for site_key, site in var.sites : {
      name                   = site_key
      bucket_name            = lookup(site, "bucket_name", "${site_key}.${data.aws_route53_zone.default.name}")
      cors_allowed_headers   = lookup(site, "cors_allowed_headers", var.default_cors_allowed_headers)
      cors_allowed_methods   = lookup(site, "cors_allowed_methods", var.default_cors_allowed_methods)
      index_document         = lookup(site, "index_document", var.default_index_document)
      error_document         = lookup(site, "error_document", var.default_error_document)
      files_path             = lookup(site, "files_path", site_key)
      file_list              = fileset("${lookup(site, "files_path", site_key)}/", "**")
      cloudfront_min_ttl     = lookup(site, "cloudfront_min_ttl", var.default_cloudfront_min_ttl)
      cloudfront_default_ttl = lookup(site, "cloudfront_default_ttl", var.default_cloudfront_default_ttl)
      cloudfront_max_ttl     = lookup(site, "cloudfront_max_ttl", var.default_cloudfront_max_ttl)
    }
  ])

  files = flatten([for site in local.sites : [
    for file in site.file_list : {
      bucket_name = site.bucket_name
      files_path  = site.files_path
      file        = file
    }
  ]])

  buckets = { for site in local.sites : site.bucket_name => site }

  mime_types = jsondecode(file("${path.module}/mime.json"))
}