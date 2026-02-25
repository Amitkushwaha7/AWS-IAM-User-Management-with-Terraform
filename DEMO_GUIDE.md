# AWS IAM Automation with Terraform


## 1) Project Objective
The objective of this project is to automate:
- IAM user creation
- Group-based access control
- Custom and managed policy attachment
- Account-wide password enforcement
- MFA enforcement for privileged users
- Remote state management with locking

All using Terraform and a structured CSV input file.

## 2) Initial Project Setup
Create a working directory:
```
AWS-IAM-User-Management-with-Terraform/
└── terraform/
```

All Terraform configuration files are placed inside the terraform/ directory.

## 3) Configure Terraform Backend
File: backend.tf

The backend is configured to:
- Store state remotely in S3
- Enable state locking using DynamoDB

Example structure:
```hcl
terraform {
	backend "s3" {
		bucket         = "your-s3-bucket"
		key            = "terraform/terraform.tfstate"
		region         = "us-east-1"
		dynamodb_table = "terraform-locks"
		encrypt        = true
	}
}
```

This ensures:
- Centralized state storage
- Prevention of concurrent terraform apply operations

## 4) Configure Provider
File: provider.tf

```hcl
provider "aws" {
	region = "us-east-1"
}
```

This connects Terraform to AWS.

## 5) Lock Terraform Versions
File: versions.tf

This ensures consistent Terraform and provider versions across environments.

## 6) Define Input Data (users.csv)
File: users.csv

Users are defined in CSV format:
```
first_name,last_name,email,phone,employee_id,department,job_title
```

This file becomes the single source of truth for IAM user provisioning.

## 7) Create IAM Users Dynamically
File: main.tf

Step 1: Parse CSV

Terraform uses:
```
csvdecode(file("${path.module}/users.csv"))
```

Step 2: Create Users Using for_each
```hcl
resource "aws_iam_user" "users" {
	for_each = { ... }
}
```

Each user:
- Is created dynamically
- Receives structured tags
- Gets a standardized username

Step 3: Create Login Profiles
```
resource "aws_iam_user_login_profile" "users"
```

Console login enabled

Password reset required on first login

## 8) Implement Role-Based Access Control
### 8.1) Create Groups
File: groups.tf

Three IAM groups are created:
- Education
- Managers
- Engineers

### 8.2) Dynamic Group Membership
File: locals.tf

Users are filtered dynamically:
```hcl
locals {
	education_users = [...]
	manager_users   = [...]
	engineer_users  = [...]
}
```

Filtering rules:
- Education -> Department == "Education"
- Managers -> JobTitle matches Manager or CEO (case-insensitive)
- Engineers -> Department == "Engineering"

### 8.3) Assign Users to Groups
```
resource "aws_iam_group_membership"
```

Each group receives users based on computed locals.

## 9) Attach IAM Policies
Education Group

AWS Managed ReadOnlyAccess

Managers Group

AWS Managed AdministratorAccess

Custom MFA enforcement policy

Engineers Group

Custom EngineerEC2LimitedAccess policy
(Allows EC2 Describe, Start, Stop)

Custom policy is defined in policies.tf.

## 10) Implement MFA Enforcement
File: mfaPolicy.tf

A conditional IAM policy is created that:
- Explicitly denies actions
- When aws:MultiFactorAuthPresent is false

This ensures Managers must enable MFA before performing privileged operations.

Important behavior:
- Explicit Deny overrides Allow, even if AdministratorAccess is attached.

## 11) Configure Account-Wide Password Policy
File: passwordpolicy.tf

The following are enforced:
- Minimum password length
- Uppercase, lowercase, numbers, symbols
- Password expiration
- Password reuse prevention

This policy applies to all IAM users in the AWS account.

## 12) Initialize and Deploy
Inside terraform/ directory:
```
terraform init
terraform plan
terraform apply
```

Terraform will:
- Create IAM users
- Create groups
- Attach policies
- Apply password policy
- Configure MFA enforcement
- Store state in S3
- Lock state using DynamoDB

## 13) Validation
After deployment, verify in AWS Console:
- IAM Users are created
- Tags are applied correctly
- Group membership matches role logic
- Policies are attached to correct groups
- Password policy is active
- MFA policy exists for Managers
- S3 contains state file
- DynamoDB contains lock entries during apply

## 14) How User Lifecycle Works
Adding a User

Add row in users.csv -> Run terraform apply

Removing a User

Delete row in users.csv -> Run terraform apply

Terraform reconciles the infrastructure accordingly.

## 15) Project Outcome
This implementation demonstrates:
- Data-driven identity provisioning
- Rule-based RBAC
- Explicit deny security enforcement
- Account-level governance configuration
- Safe and collaborative Terraform backend setup

IAM configuration is fully reproducible and managed as code.

