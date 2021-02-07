# static-website-s3-cloudfront

This module uses S3 and CloudFront to provision a static website on AWS.

## Result

The result of this module is that going on XYZ.cloudfront.net, you see your website.
If you want a custom domain (like example.com), then you need to specify variables `https_certificate_arn` and `aliases`

NOTE: this module doesn't provision automatically the certificates.

## Resources created
- a S3 bucket 
- a policy allowing access to S3 only to CloudFront
- a CloudFront distribution
