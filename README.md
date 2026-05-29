# TodoList Infrastructure

This repository contains Azure Bicep infrastructure-as-code and Azure DevOps pipeline definitions for deploying the TodoList application to Azure App Services.

## Architecture

The deployment creates:

- **App Service Plan (Linux)** - Shared compute for both applications
- **Web App 1: .NET 8 API** - RESTful API service (`todoapi-{environment}`)
- **Web App 2: React Frontend** - Static SPA served from App Service (`todoweb-{environment}`)

## Prerequisites

- Azure Subscription with appropriate permissions
- Azure DevOps Project
- Service Connection to Azure in Azure DevOps
- GitHub repository access for source code

## Infrastructure Components

### Bicep Files

- **`bicep/main.bicep`** - Main infrastructure template
  - App Service Plan (Linux, configurable SKU)
  - .NET 8 API App Service
  - React Frontend App Service (Node.js 18 LTS)

- **`bicep/parameters.bicep`** - Parameter definitions and defaults

### Configuration

#### Environment Variables

- `environment`: 'dev' or 'prod' (affects naming and resource SKU)
- `location`: Azure region (default: 'eastus')
- `appServicePlanSku`: Service plan tier (default: 'B1' for dev, 'B2' for prod)

#### App Service Configuration

**API (.NET)**
- Runtime: .NET 8.0
- Always On: Enabled
- HTTP/2 Enabled
- Min TLS: 1.2
- HTTPS Only: Enabled

**Frontend (React)**
- Runtime: Node.js 18 LTS
- Always On: Enabled
- HTTP/2 Enabled
- Min TLS: 1.2
- HTTPS Only: Enabled
- Static site with SPA routing support

## Pipeline Overview

### `azure-pipelines.yml`

The pipeline has three stages:

#### 1. **Build Stage**
- Build .NET API (Release configuration)
- Build React App (npm build)
- Validate Bicep templates

#### 2. **Deploy to Dev**
- Deploy infrastructure via Bicep
- Deploy .NET API to App Service
- Deploy React app to App Service
- Runs on all branches

#### 3. **Deploy to Prod**
- Same deployment process
- Requires approval
- Only runs on `main` branch
- Uses larger App Service Plan (B2)

## Setup Instructions

### 1. Azure DevOps Configuration

1. Create a Service Connection in Azure DevOps:
   - Project Settings → Service Connections
   - Create "Azure Resource Manager" connection
   - Name it "Azure Subscription"

2. Create environments:
   - Pipelines → Environments
   - Create "dev" environment
   - Create "prod" environment (add approval checks)

3. Set pipeline variables:
   - Go to Pipelines → Edit `azure-pipelines.yml`
   - Add variable: `AZURE_SUBSCRIPTION_ID` (your Azure subscription ID)

### 2. Repository Configuration

Link this repository to Azure DevOps:
1. Pipelines → New Pipeline
2. Select GitHub
3. Choose this repository
4. Select "Existing Azure Pipelines YAML file"
5. Path: `azure-pipelines.yml`

### 3. Manual Deployment (Optional)

To deploy using Azure CLI:

```bash
# Validate template
az bicep build --file bicep/main.bicep

# Deploy to Dev
az deployment group create \
  --name todolist-dev-deployment \
  --resource-group rg-todolist-dev \
  --template-file bicep/main.bicep \
  --parameters environment=dev appServicePlanSku=B1

# Deploy to Production
az deployment group create \
  --name todolist-prod-deployment \
  --resource-group rg-todolist-prod \
  --template-file bicep/main.bicep \
  --parameters environment=prod appServicePlanSku=B2
```

## Deployment Output

After successful deployment, the pipeline outputs:
- `appServicePlanId` - Resource ID of the App Service Plan
- `appServicePlanName` - Name of the App Service Plan
- `dotnetApiAppName` - Name of the API App Service
- `dotnetApiAppUrl` - URL to access the API
- `reactAppName` - Name of the Frontend App Service
- `reactAppUrl` - URL to access the frontend

Example URLs:
- API: `https://todoapi-dev-xyz123.azurewebsites.net`
- Frontend: `https://todoweb-dev-xyz123.azurewebsites.net`

## Monitoring & Troubleshooting

### View Deployment Status
```bash
# Check recent deployments
az deployment group list --resource-group rg-todolist-dev

# Get specific deployment details
az deployment group show --name todolist-dev-deployment --resource-group rg-todolist-dev
```

### View App Logs
```bash
# Stream .NET API logs
az webapp log tail --resource-group rg-todolist-dev --name todoapi-dev-xyz123

# Stream React app logs
az webapp log tail --resource-group rg-todolist-dev --name todoweb-dev-xyz123
```

### Scale App Service Plan
```bash
az appservice plan update \
  --resource-group rg-todolist-dev \
  --name asp-todolist-dev-xyz123 \
  --sku B2
```

## File Structure

```
.
├── bicep/
│   ├── main.bicep           # Main infrastructure template
│   └── parameters.bicep     # Parameter definitions
├── azure-pipelines.yml      # Azure DevOps pipeline
└── README.md               # This file
```

## Cost Optimization

- **Dev**: B1 SKU (~$0.11/day)
- **Prod**: B2 SKU (~$0.22/day)
- Both use shared App Service Plan
- Scale up/down based on demand

## Security Best Practices

✓ HTTPS Only enabled
✓ TLS 1.2 minimum
✓ No hardcoded secrets (use Key Vault for prod)
✓ Resource naming includes environment

### Recommended Additions (Future)

- Azure Key Vault for secrets management
- Application Insights for monitoring
- Azure Front Door for CDN/DDoS protection
- Azure SQL Database for data persistence

## Troubleshooting Common Issues

### Pipeline Fails on Bicep Validation
- Ensure Azure CLI is installed on build agent
- Check service connection permissions

### App Service Deployment Fails
- Verify app names in pipeline match resource names
- Check App Service diagnostic logs
- Ensure deployment package format is correct (.zip for .NET, dist folder for React)

### React App Shows 404
- Verify SPA routing is configured
- Check that `dist` folder is deployed
- Verify `web.config` for static file serving

## License

This infrastructure code is part of the TodoList project.

## Support

For issues, refer to the main [TodoList repository](https://github.com/RenatoMairesseJr/TodoList).
