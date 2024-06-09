# Basic Project 1 - Hosting static Website on AWS
[![Deploy React App to S3](https://github.com/enricogoerlitz/aws-bp-1-static-website-hosting/actions/workflows/deploy-react-app-to-s3.yml/badge.svg)](https://github.com/enricogoerlitz/aws-bp-1-static-website-hosting/actions/workflows/deploy-react-app-to-s3.yml)

<br>

# Architecture

## Description

This project demonstrates how to deploy a React application using AWS CloudFront and S3 for hosting. The architecture involves registering a domain with Route53 to make the CloudFront-distributed app accessible via a custom URL (bp1.enricogoerlitz.com). The infrastructure setup is managed through Terraform, while GitHub Actions is used for continuous integration and deployment.

<br>

![Architecture Diagram](architecture_.png)

<br>

# Workingtasks

## 1. Configuration by Console

## 2. Terraform deployment

Setting up Infrastructure
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## 3. CI/CD Pipeline

**GitHub Workflow Steps:**
1. Setup CI/CD Server
2. Build React-App
3. Configure AWS Credentials
4. Clear S3 Bucket
5. Copy generated build folder to S3 Bucket

<br>

# Detailed Steps:

### 1. Deploy React App with AWS CloudFront and S3:

The React application is built and stored in an S3 bucket.
AWS CloudFront is configured to serve the content from the S3 bucket, ensuring fast and secure delivery.

### 2. Register Domain in Route53:

A custom domain (bp1.enricogoerlitz.com) is registered using AWS Route53.
The domain is configured to point to the CloudFront distribution, making the React app accessible via the custom URL.

### 3. Using Terraform (Local) to Create AWS Infrastructure:

Terraform scripts are used to automate the creation of the necessary AWS resources, including the S3 bucket, CloudFront distribution, and Route53 domain setup.
This ensures a consistent and reproducible infrastructure setup.

### 4. Using GitHub for Storing Git Repository:

The project's source code and Terraform configurations are stored in a GitHub repository.
This allows for version control and collaboration.

### 5. Using GitHub Actions for CI/CD Pipeline to Build and Deploy React App to S3 Bucket:

GitHub Actions are utilized to automate the CI/CD pipeline.
The pipeline includes steps to build the React application, configure AWS credentials, clear the S3 bucket, and deploy the new build to the S3 bucket.
This ensures that every code change is automatically tested and deployed, streamlining the development workflow.
