resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.project_name}-${var.environment}-${random_id.suffix.hex}"
}

# S3 Bucket

resource "aws_s3_bucket" "vault" {
  bucket        = local.bucket_name
  force_destroy = false

  tags = {
    Name = local.bucket_name
    Role = "Disaster-Recovery-Backup"
  }
}

# Block all public access

resource "aws_s3_bucket_public_access_block" "vault" {
  bucket = aws_s3_bucket.vault.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning

resource "aws_s3_bucket_versioning" "vault" {
  bucket = aws_s3_bucket.vault.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption

resource "aws_s3_bucket_server_side_encryption_configuration" "vault" {
  bucket = aws_s3_bucket.vault.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enforce bucket ownership

resource "aws_s3_bucket_ownership_controls" "vault" {
  bucket = aws_s3_bucket.vault.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Lifecycle management

resource "aws_s3_bucket_lifecycle_configuration" "vault" {
  bucket = aws_s3_bucket.vault.id

  depends_on = [
    aws_s3_bucket_versioning.vault
  ]

  rule {
    id     = "backup-version-retention"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Secure HTTPS-only bucket policy

resource "aws_s3_bucket_policy" "vault" {
  bucket = aws_s3_bucket.vault.id

  policy = templatefile(
    "${path.module}/../policies/bucket-policy.json",
    {
      bucket_arn = aws_s3_bucket.vault.arn
    }
  )

  depends_on = [
    aws_s3_bucket_public_access_block.vault
  ]
}