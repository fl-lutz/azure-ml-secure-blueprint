@description('The name of the machine learning workspace')
param machineLearningWorkspaceName string

@description('The location of the machine learning workspace')
param location string

@description('The application insights id')
param applicationInsightsId string

@description('The storage account id')
param storageAccountId string

@description('The container registry id')
param containerRegistryId string

@description('The key vault id')
param keyVaultId string

@description('The user assigned identity id')
param managedIdentityId string

@description('The open ai workspace id')
param openAiWorkspaceId string

resource machineLearningWorkspace 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
  name: machineLearningWorkspaceName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    applicationInsights: applicationInsightsId
    storageAccount: storageAccountId
    containerRegistry: containerRegistryId
    keyVault: keyVaultId
    imageBuildCompute: 'cpu-compute'
    primaryUserAssignedIdentity: managedIdentityId
    publicNetworkAccess: 'Disabled'
    managedNetwork: {
      isolationMode: 'AllowInternetOutbound'
      outboundRules: {
        allowOpenAi: {
          type: 'PrivateEndpoint'
          destination: {
            serviceResourceId: openAiWorkspaceId
            sparkEnabled: true
            subresourceTarget: 'account'
          }
        }
      }
    }
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

output machineLearningWorkspaceId string = machineLearningWorkspace.id
output machineLearningWorkspaceName string = machineLearningWorkspace.name
