@description('The storage account name')
param storageName string

@description('The location')
param location string

@description('The managed identity principal id')
param managedIdentityPrincipalId string

@description('The network connection approver role definition id.')
var networkConnectionApproverRoleDefinitionId = 'b556d68e-0be0-4f35-a333-ad7ee1ce17ea'

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
  }
}

// resource connectionApproverAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(storage.id, managedIdentityPrincipalId, networkConnectionApproverRoleDefinitionId)
//   scope: storage
//   properties: {
//     principalId: managedIdentityPrincipalId
//     roleDefinitionId: networkConnectionApproverRoleDefinitionId
//     principalType: 'ServicePrincipal'
//   }
// }

output storageAccountName string = storage.name
output storageAccountId string = storage.id
output storageAccountKey string = storage.listKeys().keys[0].value
