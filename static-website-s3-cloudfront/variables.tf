variable "geo_restriction" {
  description = "CloudFront geo_restriction"

  type = object({
    restriction_type = string
    locations        = list(string)
  })
  default = {
    restriction_type = "none" # Can be "none", "whitelist", "blacklist"
    locations        = null   # A list of countries. Example: ["US", GB"]
  }
}

variable "https_certificate_arn" {
  description = "The ARN of the certificate, must be in the us-east-1 region (North Virginia)"
}

variable "bucket_name" {
  description = "The bucket for the static website"
  type        = string
}

variable "aliases" {
  description = "Aliases of CloudFront CDN: Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
}
