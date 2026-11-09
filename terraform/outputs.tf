output "bucket_name" {
  description = "Created S3 bucket name"
  value       = aws_s3_bucket.vault.bucket
}

output "bucket_arn" {
  description = "Created S3 bucket ARN"
  value       = aws_s3_bucket.vault.arn
}

output "bucket_region" {
  description = "S3 bucket region"
  value       = var.aws_region
}

output "versioning_status" {
  description = "S3 versioning status"
  value       = aws_s3_bucket_versioning.vault.versioning_configuration[0].status
}