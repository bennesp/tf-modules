resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  versioning {
    enabled = true
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "access-identity-${aws_s3_bucket.bucket.bucket}.s3.eu-west-1.amazonaws.com"
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  is_ipv6_enabled = true

  aliases = var.aliases != null ? var.aliases : []

  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.bucket.bucket

    viewer_protocol_policy = var.https_certificate_arn != null ? "redirect-to-https" : "allow-all" # One of allow-all, https-only, or redirect-to-https.
    forwarded_values {
      query_string = false
      headers      = []
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.https_certificate_arn != null ? false : true
    acm_certificate_arn            = var.https_certificate_arn != null ? var.https_certificate_arn : null
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
  }
}
