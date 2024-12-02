@description('The key vault names')
param keyVaultName string

@description('The locations')
param location string

@description('The managed identity pricial id')
param managedIdentityPrincipalId string

@description('The network connection approver role definition id.')
var networkConnectionApproverRoleDefinitionId = 'b556d68e-0be0-4f35-a333-ad7ee1ce17ea'

@description('The public network access')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: managedIdentityPrincipalId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
            'delete'
          ]
          certificates: [
            'get'
            'list'
            'create'
            'update'
          ]
          keys: [
            'get'
            'list'
            'create'
            'update'
          ]
        }
      }
    ]
    publicNetworkAccess: publicNetworkAccess
    networkAcls: publicNetworkAccess == 'Disabled'
      ? {
          defaultAction: 'Deny'
          bypass: 'AzureServices'
          virtualNetworkRules: []
          ipRules: []
        }
      : {}
  }
}

// resource connectionApproverAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(keyVault.id, managedIdentityPrincipalId, networkConnectionApproverRoleDefinitionId)
//   scope: keyVault
//   properties: {
//     principalId: managedIdentityPrincipalId
//     roleDefinitionId: networkConnectionApproverRoleDefinitionId
//     principalType: 'ServicePrincipal'
//   }
// }

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
