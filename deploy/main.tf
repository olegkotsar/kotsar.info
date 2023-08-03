# Create bucket.
resource "aws_s3_bucket" "webpage_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "webpage"
    source      = "terraform"
  }
}

# Upload file.
resource "aws_s3_object" "webpage_upload" {
  bucket = aws_s3_bucket.webpage_bucket.id
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"

  etag = filemd5("index.html")
}

# Configure statis website.
resource "aws_s3_bucket_website_configuration" "webpage_configuration" {
  bucket = aws_s3_bucket.webpage_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Grant read only policy.
resource "aws_s3_bucket_policy" "webpage-policy" {
  bucket = aws_s3_bucket.webpage_bucket.id
  # can use file
  #policy = templatefile("s3-policy.json", { bucket = var.bucket_name })
  policy = data.aws_iam_policy_document.allow_read_access_for_all.json
}

data "aws_iam_policy_document" "allow_read_access_for_all" {
  statement {
    sid = "PublicReadGetObject"
    actions = [
      "s3:GetObject",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*",
    ]
    effect = "Allow"
  }
}

output "website_domain" {
  value = aws_s3_bucket_website_configuration.webpage_configuration.website_domain
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.webpage_configuration.website_endpoint
}
