
resource "aws_s3_bucket" "redirect" {
  bucket = data.aws_route53_zone.default.name
  acl    = "public-read"
  policy = templatefile("${path.module}/templates/s3-policy.json", {
    bucket = data.aws_route53_zone.default.name
  })

  website {
    redirect_all_requests_to = "https://${var.default_site}.${data.aws_route53_zone.default.name}"
  }

  tags = merge(var.default_tags, {
    Name = data.aws_route53_zone.default.name
  })
}

resource "aws_s3_bucket" "sites" {
  for_each = local.buckets
  bucket   = each.value.bucket_name
  acl      = "public-read"
  policy = templatefile("${path.module}/templates/s3-policy.json", {
    bucket = each.value.bucket_name
  })

  cors_rule {
    allowed_headers = each.value.cors_allowed_headers
    allowed_methods = each.value.cors_allowed_methods
    allowed_origins = ["https://${each.value.name}.${data.aws_route53_zone.default.name}"]
    max_age_seconds = 3000
  }

  website {
    index_document = each.value.index_document
    error_document = each.value.error_document
  }

  tags = merge(var.default_tags, {
    Name = each.value.bucket_name
  })
}

resource "aws_s3_bucket_object" "files" {
  count        = length(local.files)
  bucket       = local.files[count.index].bucket_name
  key          = local.files[count.index].file
  content      = file("${local.files[count.index].files_path}/${local.files[count.index].file}")
  etag         = filemd5("${local.files[count.index].files_path}/${local.files[count.index].file}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", local.files[count.index].file), "application/octet-stream")

  depends_on = [
    aws_s3_bucket.sites
  ]
}