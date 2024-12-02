@description('The managed identity name.')
param managedIdentityName string

@description('The main location.')
param location string

@description('The network connection approver role definition id.')
var networkConnectionApproverRoleDefinitionId = 'b556d68e-0be0-4f35-a333-ad7ee1ce17ea'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

resource connectionApproverAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, networkConnectionApproverRoleDefinitionId, managedIdentity.name)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', networkConnectionApproverRoleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

output managedIdentityId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
