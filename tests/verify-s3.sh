#!/bin/bash

set -euo pipefail

BUCKET="${1:-}"

if [[ -z "$BUCKET" ]]; then
    echo "Usage: ./tests/verify-s3.sh BUCKET_NAME"
    exit 1
fi

echo "Starting S3 security verification..."
echo "Bucket: $BUCKET"

# Test 1: Public access protection

aws s3api get-public-access-block \
    --bucket "$BUCKET" > /tmp/s3-public.json

jq -e '
.PublicAccessBlockConfiguration |
.block_public_acls == true and
.block_public_policy == true and
.ignore_public_acls == true and
.restrict_public_buckets == true
' /tmp/s3-public.json > /dev/null

echo "[PASS] Public access blocked"

# Test 2: Versioning

VERSIONING=$(aws s3api get-bucket-versioning \
    --bucket "$BUCKET" \
    --query Status \
    --output text)

[[ "$VERSIONING" == "Enabled" ]]

echo "[PASS] Versioning enabled"

# Test 3: Encryption

ENCRYPTION=$(aws s3api get-bucket-encryption \
    --bucket "$BUCKET" \
    --query 'Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' \
    --output text)

[[ "$ENCRYPTION" == "AES256" ]]

echo "[PASS] AES256 encryption enabled"

# Test 4: HTTPS-only policy

aws s3api get-bucket-policy \
    --bucket "$BUCKET" \
    --query Policy \
    --output text |
jq -e '
.Statement[] |
select(.Sid == "DenyInsecureTransport") |
.Effect == "Deny" and
.Condition.Bool["aws:SecureTransport"] == "false"
' > /dev/null

echo "[PASS] HTTPS-only bucket policy"

echo "--------------------------------"
echo "All S3 security tests passed!"
echo "--------------------------------"