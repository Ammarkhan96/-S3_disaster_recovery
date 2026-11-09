# Terraform Secure S3 Disaster Recovery Vault

## Overview

This project provisions a secure AWS S3 backup vault
using Terraform Infrastructure as Code.

It focuses on data protection, backup recovery,
security enforcement and infrastructure automation.

## Architecture

- Terraform provisions AWS infrastructure.
- Amazon S3 stores backup objects.
- S3 Versioning protects previous object versions.
- AES256 provides server-side encryption.
- Public Access Block prevents public exposure.
- Bucket Policy denies insecure HTTP requests.
- Lifecycle configuration manages old versions.
- GitHub Actions validates Terraform.
- Checkov scans infrastructure security.

## Technologies

- AWS S3
- Terraform
- AWS CLI
- GitHub Actions
- Checkov
- Bash
- Linux

## Project Structure

```text
terraform-s3-dr-vault/
├── terraform/
├── policies/
├── tests/
├── .github/workflows/
├── .gitignore
└── README.md