
module "example" {
  source = "git@github.com:kuffel/aws-s3-websites.git?ref=1.0.0"

  # The module will extract the TLD from the name of the given zone (e.g. example.com).
  route53_zone_id = "[YOUR_HOSTED_ZONE_ID]"
  # Create a wildcard certificate for the TLD (must be in us-east-1)
  certificate_arn = "[YOUR_CERTIFICATE_ARN]"

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
