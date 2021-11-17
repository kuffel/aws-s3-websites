
resource "aws_cloudfront_distribution" "redirect" {
  comment = "${data.aws_route53_zone.default.name} - Redirects"

  origin {
    domain_name = aws_s3_bucket.redirect.website_endpoint
    origin_id   = "S3-${data.aws_route53_zone.default.name}"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  price_class     = var.default_cloudfront_distribution_price_class
  enabled         = true
  is_ipv6_enabled = true

  aliases = [data.aws_route53_zone.default.name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${data.aws_route53_zone.default.name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }

      headers = ["Origin"]
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = var.default_cloudfront_min_ttl
    default_ttl            = var.default_cloudfront_default_ttl
    max_ttl                = var.default_cloudfront_max_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = merge(var.default_tags, {
    Description = data.aws_route53_zone.default.name
  })
}


resource "aws_cloudfront_distribution" "site" {
  for_each = local.buckets
  comment  = "${each.key} - S3 Hosting"

  origin {
    domain_name = aws_s3_bucket.sites[each.key].website_endpoint
    origin_id   = "S3-${each.key}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  price_class         = var.default_cloudfront_distribution_price_class
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = each.value.index_document

  aliases = [each.key]

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/${each.value.error_document}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${each.key}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = each.value.cloudfront_min_ttl
    default_ttl            = each.value.cloudfront_default_ttl
    max_ttl                = each.value.cloudfront_max_ttl

    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = merge(var.default_tags, {
    Description = each.key
  })
}