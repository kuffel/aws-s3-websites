
output "hosted_zone_name" {
  value = data.aws_route53_zone.default.name
}

output "sites" {
  value = [for site in local.sites : site.bucket_name]
}