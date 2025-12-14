# GitHub Actions Setup

Quick guide to set up automated Terraform deployments.

## What it does

- Runs `terraform plan` on pull requests (posts results as comment)
- Runs `terraform apply` when merged to main
- Tests the API after deployment
- Posts deployment summary with API URL

## Setup

### 1. Create AWS IAM User

Create an IAM user for GitHub Actions:

```bash
# Via AWS Console:
# - IAM → Users → Create user
# - Name: github-actions-terraform
# - Attach policies: VPC, ECR, Lambda, API Gateway, CloudWatch, IAM
# - Save the access key and secret
```

### 2. Add GitHub Secrets

Go to your repo Settings → Secrets and variables → Actions, then add:

- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret key

### 3. Optional: Environment Protection

For manual approval before deployment:

- Settings → Environments → Create `production`
- Add required reviewers
- Set deployment branch to `main` only

## How it works

**On Pull Request:**
- Runs `terraform plan`
- Posts plan as PR comment
- No changes applied

**On Push to Main:**
- Runs `terraform apply`
- Waits for approval (if environment protection enabled)
- Tests the API
- Posts deployment summary

**Manual Trigger:**
- Actions tab → Terraform Apply → Run workflow

## Troubleshooting

**AWS credentials error:**
Check secrets are set correctly in Settings → Secrets

**Terraform init failed:**
Verify AWS permissions and backend config

**Docker build failed:**
Test the build locally first

**Workflow not triggering:**
Make sure changes are in `terraform/` directory

## Customization

Change region or Terraform version in `.github/workflows/terraform-apply.yml`:

```yaml
env:
  AWS_REGION: us-east-1
  TERRAFORM_VERSION: 1.6.0
```

That's it. Push to main or create a PR to see it in action.
