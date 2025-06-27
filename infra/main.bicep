@minLength(2)
@maxLength(50)
@description('Custom name for the Azure Container Registry. Must be globally unique and 5-50 alphanumeric characters.')
param acrName string ='essdevacrtemp'

@minLength(1)
@maxLength(64)
@description('Name of the environment')
param environmentName string = 'dev'

@description('Id of the user or app to assign application roles')
param principalId string = '6bbb29a1-ec8e-4b3a-849e-9ebb77bde171'

@minLength(1)
@description('The location used for all deployed resources')
param location string = 'uksouth'

var tags = {
  'azd-env-name': environmentName
}

module resources 'modules/environment.bicep' = {
  name: 'resources'
  params: {
    location: location
    tags: tags
    acrName: acrName
    environmentName: environmentName
  }
}

output MANAGED_IDENTITY_CLIENT_ID string = resources.outputs.MANAGED_IDENTITY_CLIENT_ID
output MANAGED_IDENTITY_NAME string = resources.outputs.MANAGED_IDENTITY_NAME
output MANAGED_IDENTITY_PRINCIPAL_ID string = resources.outputs.MANAGED_IDENTITY_PRINCIPAL_ID
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = resources.outputs.AZURE_CONTAINER_REGISTRY_ENDPOINT
output AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID string = resources.outputs.AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID
output AZURE_CONTAINER_REGISTRY_NAME string = resources.outputs.AZURE_CONTAINER_REGISTRY_NAME