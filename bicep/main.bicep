param location string = resourceGroup().location
param environment string = 'dev'
param appServicePlanSku string = 'B1'
param dotnetApiName string = 'todoapi'
param reactFrontendName string = 'todoweb'

var uniqueSuffix = uniqueString(resourceGroup().id)
var appServicePlanName = 'asp-todolist-${environment}-${uniqueSuffix}'
var dotnetAppName = '${dotnetApiName}-${environment}-${uniqueSuffix}'
var reactAppName = '${reactFrontendName}-${environment}-${uniqueSuffix}'

// App Service Plan (shared)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    capacity: 1
  }
  kind: 'Linux'
  properties: {
    reserved: true
  }
}

// .NET API App Service
resource dotnetApiApp 'Microsoft.Web/sites@2023-01-01' = {
  name: dotnetAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNET|8.0'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environment
        }
        {
          name: 'ASPNETCORE_URLS'
          value: 'http://+:80'
        }
      ]
    }
    httpsOnly: true
  }
}

// React Frontend App Service (static site)
resource reactApp 'Microsoft.Web/sites@2023-01-01' = {
  name: reactAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'NODE_ENV'
          value: 'production'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '18-lts'
        }
      ]
      defaultDocuments: [
        'index.html'
      ]
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot\\dist'
          preloadEnabled: true
        }
      ]
    }
    httpsOnly: true
  }
}

// Configure web.config for React routing (SPA fallback)
resource reactWebConfig 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: reactApp
  name: 'web'
  properties: {
    numberOfWorkerProcesses: 1
    defaultDocuments: [
      'index.html'
    ]
  }
}

output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name

output dotnetApiAppId string = dotnetApiApp.id
output dotnetApiAppName string = dotnetApiApp.name
output dotnetApiAppUrl string = 'https://${dotnetApiApp.properties.defaultHostName}'

output reactAppId string = reactApp.id
output reactAppName string = reactApp.name
output reactAppUrl string = 'https://${reactApp.properties.defaultHostName}'
