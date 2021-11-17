
data "aws_route53_zone" "default" {
  zone_id = var.route53_zone_id
}

resource "aws_route53_record" "redirect_a" {
  zone_id = var.route53_zone_id
  name    = data.aws_route53_zone.default.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect_aaaa" {
  zone_id = var.route53_zone_id
  name    = data.aws_route53_zone.default.name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_a" {
  for_each = local.buckets

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site[each.value.bucket_name].domain_name
    zone_id                = aws_cloudfront_distribution.site[each.value.bucket_name].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_aaaa" {
  for_each = local.buckets

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site[each.value.bucket_name].domain_name
    zone_id                = aws_cloudfront_distribution.site[each.value.bucket_name].hosted_zone_id
    evaluate_target_health = false
  }
}