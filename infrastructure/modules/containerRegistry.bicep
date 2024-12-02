@description('The container registry name.')
param containerRegistryName string

@description('The location')
param location string

@description('The container registry sku')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string

@description('The managed identity pricial id')
param managedIdentityPrincipalId string

@description('The network connection approver role definition id.')
var networkConnectionApproverRoleDefinitionId = 'b556d68e-0be0-4f35-a333-ad7ee1ce17ea'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: sku
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    adminUserEnabled: false
    networkRuleBypassOptions: 'AzureServices'
  }
}

// resource connectionApproverAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(containerRegistry.id, managedIdentityPrincipalId, networkConnectionApproverRoleDefinitionId)
//   scope: containerRegistry
//   properties: {
//     principalId: managedIdentityPrincipalId
//     roleDefinitionId: networkConnectionApproverRoleDefinitionId
//     principalType: 'ServicePrincipal'
//   }
// }

output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer
output containerRegistryId string = containerRegistry.id
