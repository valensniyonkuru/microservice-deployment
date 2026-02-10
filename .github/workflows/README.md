# GitHub Actions Workflow

## Deploy to Production

**File**: `deploy.yml`

### What it does

1. **Build** - Builds Docker images for all services
2. **Infrastructure** - Deploys AWS infrastructure with Terraform
3. **Deploy** - Updates ECS services
4. **Verify** - Checks service health

### Triggers

- Push to `main` branch (automatic)
- Manual trigger via GitHub Actions UI

### Required Secrets

Configure in Settings → Secrets → Actions:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DATABASE_PASSWORD`
- `RABBITMQ_PASSWORD`
- `JWT_SECRET`

### Duration

Approximately 15-20 minutes for full deployment.

### Monitoring

View progress in GitHub Actions tab. Each job shows detailed logs and status.
