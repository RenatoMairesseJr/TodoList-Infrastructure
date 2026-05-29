param location string = 'eastus'
param environment string = 'dev'
param appServicePlanSku string = 'B1'

module appServices 'main.bicep' = {
  name: 'appServicesDeployment'
  params: {
    location: location
    environment: environment
    appServicePlanSku: appServicePlanSku
    dotnetApiName: 'todoapi'
    reactFrontendName: 'todoweb'
  }
}

output appServicePlanId string = appServices.outputs.appServicePlanId
output appServicePlanName string = appServices.outputs.appServicePlanName
output dotnetApiAppId string = appServices.outputs.dotnetApiAppId
output dotnetApiAppName string = appServices.outputs.dotnetApiAppName
output dotnetApiAppUrl string = appServices.outputs.dotnetApiAppUrl
output reactAppId string = appServices.outputs.reactAppId
output reactAppName string = appServices.outputs.reactAppName
output reactAppUrl string = appServices.outputs.reactAppUrl
