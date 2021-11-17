
variable "route53_zone_id" {
  description = "Hosted Zone ID for the route53 entries"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the wildcard HTTPS certificate for the domain (must be in us-east-1)"
  type        = string
}

variable "default_site" {
  description = "Requests to the TLD without subdomain will be redirected to this site"
  type        = string
  default     = "www"
}

variable "default_tags" {
  description = "Default tags that will be attached to all created resources"
  type        = map(any)
  default     = {}
}

variable "sites" {
  description = "Map of subdomains to deploy, the key will be used to create the DNS records and bucket name."
  /*
  type = map(object({
    bucket_name            = optional(string)
    cors_allowed_headers   = optional(list(string))
    cors_allowed_methods   = optional(list(string))
    index_document         = optional(string)
    error_document         = optional(string)
    files_path             = optional(string)
    cloudfront_min_ttl     = optional(number)
    cloudfront_default_ttl = optional(number)
    cloudfront_max_ttl     = optional(number)
  }))
  default = {
    sites = {
      "www" = {}
    }
  }
  */
}

variable "default_cors_allowed_headers" {
  description = "Default CORS headers that will be allowed by the CORS rule"
  type        = list(string)
  default     = ["Authorization", "Content-Length"]
}

variable "default_cors_allowed_methods" {
  description = "Default CORS methods that will be allowed by the CORS rule"
  type        = list(string)
  default     = ["GET", "POST"]
}

variable "default_index_document" {
  description = "Default index file for the buckets website."
  type        = string
  default     = "index.html"
}

variable "default_error_document" {
  description = "Default error file for the buckets website."
  type        = string
  default     = "error.html"
}

variable "default_cloudfront_distribution_price_class" {
  description = "Default region setting for the CloudFront price class."
  type        = string
  default     = "PriceClass_200"
}

variable "default_cloudfront_min_ttl" {
  description = "Minimal TTL for page that was cached by cloudfront."
  type        = number
  default     = 0
}

variable "default_cloudfront_default_ttl" {
  description = "Default TTL for page that was cached by cloudfront."
  type        = number
  default     = 86400
}

variable "default_cloudfront_max_ttl" {
  description = "Maximum TTL for page that was cached by cloudfront."
  type        = number
  default     = 31536000
}

