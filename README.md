# AWS S3 static websites

This terraform module can be used to host multiple static websites on S3.
It takes a Route53 hosted zone id, an ACM certificate ARM and a bunch of files
to create your static websites using S3 and Cloudfront.

## Features

- Support for different subdomains using configurable sites.
- Automatic upload of files from the given directory.
- CloudFront distribution enabled.
- SSL Support with automatic redirect.
- DNS entries created with redirect from the TLD to the subdomain.
- Automatic detection of the mimetype for the files.

## Getting started

To use this module you need a hosted zone and a wildcard certificate for the domain being used.
Assuming you already have an AWS account, please click the links below to get to the required pages.

- [Create Hosted Zone](https://console.aws.amazon.com/route53/v2/hostedzones#CreateHostedZone)
- [Create wildcard certificate](https://eu-central-1.console.aws.amazon.com/acm/home?region=eu-east-1#/certificates/request)

### Minimal example

This configuration will create a single `www` subdomain, redirect traffic
from the TLD to the subdomain. The module expects the static files in a directory `www` next to this config.

```hcl
module "example_com" {
  source = "git@github.com:kuffel/aws-s3-websites.git?ref=1.0.0"
  
  route53_zone_id = "[HOSTED_ZONE_ID]"
  certificate_arn = "[WILDCARD_CERTIFICATE_ARN]"

  sites = {
    "www" = {}
  }
}
```

### Advanced example

You can deploy multiple subdomains just by adding more sites to the map.

```hcl
module "example_com" {
  source = "git@github.com:kuffel/aws-s3-websites.git?ref=1.0.0"

  # The module will extract the TLD from the name of the given zone (e.g. example.com).
  route53_zone_id = "[HOSTED_ZONE_ID]"
  # Create a wildcard certificate for the TLD (must be in us-east-1)
  certificate_arn = "[WILDCARD_CERTIFICATE_ARN]"

  # default_site
  default_site = "www"

  # default_tags
  default_tags = {
    "Your": "Extra"
    "Tags": "For"
    "This": "Project"
  }

  # Define subdomains under the given TLD
  sites = {
    # The www site will be the default site for the redirects from the `example.com`
    "www"   = {}
    # Additional site that will be deployed under the TLD.
    "subdomain"  = {
      # The default bucket name would be "demo.example.com"
      bucket_name = "my-demo-bucket"
      # Specifiy different CORS headers for this site.
      cors_allowed_headers = ["Authorization", "Content-Length"]
      # Specifiy different CORS methods for this site.
      cors_allowed_methods = ["GET", "POST"]
      # Use a different index_document for the bucket
      index_document = "index.html"
      # Use a different error_document for the bucket
      error_document = "error.html"
      # Use a different path then a directory with the same name as the site
      files_path = "subdomain"
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.48.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.48.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_route53_record.redirect_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.redirect_aaaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.site_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.site_aaaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.sites](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_object.files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) | resource |
| [aws_route53_zone.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of the wildcard HTTPS certificate for the domain (must be in us-east-1) | `string` | n/a | yes |
| <a name="input_default_cloudfront_default_ttl"></a> [default\_cloudfront\_default\_ttl](#input\_default\_cloudfront\_default\_ttl) | Default TTL for page that was cached by cloudfront. | `number` | `86400` | no |
| <a name="input_default_cloudfront_distribution_price_class"></a> [default\_cloudfront\_distribution\_price\_class](#input\_default\_cloudfront\_distribution\_price\_class) | Default region setting for the CloudFront price class. | `string` | `"PriceClass_200"` | no |
| <a name="input_default_cloudfront_max_ttl"></a> [default\_cloudfront\_max\_ttl](#input\_default\_cloudfront\_max\_ttl) | Maximum TTL for page that was cached by cloudfront. | `number` | `31536000` | no |
| <a name="input_default_cloudfront_min_ttl"></a> [default\_cloudfront\_min\_ttl](#input\_default\_cloudfront\_min\_ttl) | Minimal TTL for page that was cached by cloudfront. | `number` | `0` | no |
| <a name="input_default_cors_allowed_headers"></a> [default\_cors\_allowed\_headers](#input\_default\_cors\_allowed\_headers) | Default CORS headers that will be allowed by the CORS rule | `list(string)` | <pre>[<br>  "Authorization",<br>  "Content-Length"<br>]</pre> | no |
| <a name="input_default_cors_allowed_methods"></a> [default\_cors\_allowed\_methods](#input\_default\_cors\_allowed\_methods) | Default CORS methods that will be allowed by the CORS rule | `list(string)` | <pre>[<br>  "GET",<br>  "POST"<br>]</pre> | no |
| <a name="input_default_error_document"></a> [default\_error\_document](#input\_default\_error\_document) | Default error file for the buckets website. | `string` | `"error.html"` | no |
| <a name="input_default_index_document"></a> [default\_index\_document](#input\_default\_index\_document) | Default index file for the buckets website. | `string` | `"index.html"` | no |
| <a name="input_default_site"></a> [default\_site](#input\_default\_site) | Requests to the TLD without subdomain will be redirected to this site | `string` | `"www"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags that will be attached to all created resources | `map(any)` | `{}` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Hosted Zone ID for the route53 entries | `string` | n/a | yes |
| <a name="input_sites"></a> [sites](#input\_sites) | Map of subdomains to deploy, the key will be used to create the DNS records and bucket name. | <pre>map(object({<br>    bucket_name            = optional(string)<br>    cors_allowed_headers   = optional(list(string))<br>    cors_allowed_methods   = optional(list(string))<br>    index_document         = optional(string)<br>    error_document         = optional(string)<br>    files_path             = optional(string)<br>    cloudfront_min_ttl     = optional(number)<br>    cloudfront_default_ttl = optional(number)<br>    cloudfront_max_ttl     = optional(number)<br>  }))</pre> | <pre>{<br>  "sites": {<br>    "www": {}<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hosted_zone_name"></a> [hosted\_zone\_name](#output\_hosted\_zone\_name) | n/a |
| <a name="output_sites"></a> [sites](#output\_sites) | n/a |
<!-- END_TF_DOCS -->
