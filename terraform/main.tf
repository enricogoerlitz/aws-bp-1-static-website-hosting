provider "aws" {
  region = "eu-central-1"
}

# CREATE S3 BUCKET
# S3 Bucket für die React App
resource "aws_s3_bucket" "react_app" {
  bucket = "bp1.enricogoerlitz.com"
}

resource "aws_s3_bucket_cors_configuration" "react_app" {
  bucket = aws_s3_bucket.react_app.id  

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
  
}

resource "aws_s3_bucket_public_access_block" "react_app" {
  bucket = aws_s3_bucket.react_app.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.react_app.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.react_app]
}

resource "aws_s3_bucket_acl" "react_app_acl" {
  bucket = aws_s3_bucket.react_app.id
  acl    = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_policy" "react_app" {
  bucket = aws_s3_bucket.react_app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::bp1.enricogoerlitz.com",
          "arn:aws:s3:::bp1.enricogoerlitz.com/*"
        ]
      },
      {
        Sid = "GitHubUserCICDAccess"
        Principal = "*"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::bp1.enricogoerlitz.com",
          "arn:aws:s3:::bp1.enricogoerlitz.com/*"
        ],
        Principal = {
          AWS = [
            "arn:aws:iam::533267024986:user/github-cicd-user"
          ]
        }
      }
    ]
  })
  
  depends_on = [aws_s3_bucket_public_access_block.react_app]
}


# Website-Konfiguration für den S3 Bucket
resource "aws_s3_bucket_website_configuration" "react_app_website" {
  bucket = aws_s3_bucket.react_app.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

  depends_on = [aws_s3_bucket_public_access_block.react_app]
}


resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    origin_id   = "S3Origin"
    domain_name = "bp1.enricogoerlitz.com.s3-website.eu-central-1.amazonaws.com"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:533267024986:certificate/34b36eca-30bc-4e85-b650-8948bb0b320f"
    ssl_support_method  = "sni-only"
  }

  aliases = ["bp1.enricogoerlitz.com"]
}

# ADD DNS RECORD
resource "aws_route53_record" "cloudfront_alias" {
  zone_id = "Z0537675234U5T8AE6L76"
  name    = "bp1.enricogoerlitz.com"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
