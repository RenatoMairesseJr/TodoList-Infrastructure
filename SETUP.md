## TodoList Infrastructure Setup Checklist

Before deploying, complete these steps:

### Azure Prerequisites
- [ ] Azure Subscription created
- [ ] Resource groups created:
  - [ ] `rg-todolist-dev` (for development)
  - [ ] `rg-todolist-prod` (for production)

### Azure DevOps Setup
- [ ] Azure DevOps Project created
- [ ] Service Connection established:
  - [ ] Go to Project Settings → Service Connections
  - [ ] Create Azure Resource Manager connection
  - [ ] Name it "Azure Subscription"
  - [ ] Grant permissions to created resource groups

### Environment Configuration
- [ ] Create pipeline environments:
  - [ ] Dev environment
  - [ ] Prod environment (set approvals/checks)
- [ ] Add pipeline variable: `AZURE_SUBSCRIPTION_ID`

### Repository Link
- [ ] GitHub repository linked to Azure DevOps
- [ ] Pipeline created from `azure-pipelines.yml`

### Code Repository Updates
- [ ] Both repositories have the required configuration:
  - [ ] TodoList (main app): Backend/.csproj and Frontend-React/package.json
  - [ ] TodoList-Infrastructure: Bicep and pipeline files

## Deployment Workflow

### Development Deployment
```bash
# Manual deployment to dev
az deployment group create \
  --name todolist-dev-$(date +%s) \
  --resource-group rg-todolist-dev \
  --template-file bicep/main.bicep \
  --parameters bicep/parameters.dev.json
```

### Production Deployment
```bash
# Manual deployment to prod (requires approval in pipeline)
az deployment group create \
  --name todolist-prod-$(date +%s) \
  --resource-group rg-todolist-prod \
  --template-file bicep/main.bicep \
  --parameters bicep/parameters.prod.json
```

## Post-Deployment Verification

After deployment, verify resources:

```bash
# List all App Services in dev
az webapp list --resource-group rg-todolist-dev --output table

# Test API endpoint
curl -I https://todoapi-dev-<suffix>.azurewebsites.net/health

# Test React app
curl -I https://todoweb-dev-<suffix>.azurewebsites.net
```

## Troubleshooting

### Cannot find resource group
```bash
# List available resource groups
az group list --output table
```

### Bicep validation fails
```bash
# Validate locally
az bicep build --file bicep/main.bicep
az bicep format --file bicep/main.bicep
```

### App Service deployment times out
- Increase deployment timeout in pipeline
- Check App Service logs: `az webapp log tail --resource-group <rg> --name <app-name>`

## Monitoring Dashboard

### Create a monitoring dashboard in Azure Portal:
1. Go to the App Service resource
2. Monitoring → Insights → Enable Application Insights
3. View metrics: CPU, Memory, Requests, Response times

## Next Steps

1. Complete setup checklist above
2. Trigger pipeline on main branch
3. Verify deployments in Azure Portal
4. Configure custom domain names (optional)
5. Set up auto-scaling policies (optional)
6. Enable diagnostics and alerts (recommended)
