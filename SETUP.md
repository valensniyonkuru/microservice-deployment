# Setup Guide

## Step 1: AWS Account

1. Create AWS account at https://aws.amazon.com
2. Create IAM user with programmatic access
3. Attach policies:
   - AmazonEC2FullAccess
   - AmazonECS_FullAccess
   - AmazonRDSFullAccess
   - AmazonMQFullAccess
   - AmazonVPCFullAccess
   - AmazonEC2ContainerRegistryFullAccess
4. Save Access Key ID and Secret Access Key

## Step 2: GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

| Secret Name | Value | Example |
|-------------|-------|---------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `DATABASE_PASSWORD` | Strong password for RDS | `MySecurePass123!` |
| `RABBITMQ_PASSWORD` | Strong password for RabbitMQ | `MySecurePass456!` |
| `JWT_SECRET` | Random 32+ character string | `your-super-secret-jwt-key-here` |

## Step 3: Configure Terraform (Optional)

Only if you want to customize infrastructure:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
```

## Step 4: Deploy

Push to main branch:

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

Go to GitHub Actions and watch the deployment.

## Step 5: Access Your Application

After deployment completes:

1. Go to GitHub Actions → Your workflow → Deploy Services → Get ALB DNS
2. Access services:
   - Books: `http://<ALB-DNS>/books`
   - Customers: `http://<ALB-DNS>/customers`
   - Orders: `http://<ALB-DNS>/orders`

## Troubleshooting

### Pipeline Fails

1. Check GitHub Actions logs
2. Verify all secrets are set correctly
3. Ensure AWS credentials have correct permissions

### Services Unhealthy

1. Check ECS service events in AWS Console
2. Verify security group rules
3. Check database connectivity

### Can't Access Services

1. Wait 2-3 minutes after deployment
2. Check ALB DNS is correct
3. Try health endpoints: `http://<ALB-DNS>/books/health`

## Next Steps

- Set up custom domain with Route 53
- Add HTTPS certificate with ACM
- Configure auto-scaling thresholds
- Set up monitoring alarms

## Cleanup

To destroy all resources:

1. GitHub → Actions
2. Deploy to Production workflow
3. Run workflow → Select "destroy"

**Warning**: This deletes everything including database data.
