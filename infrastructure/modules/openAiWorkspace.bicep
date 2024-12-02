@description('The name of the openai workspace')
param workspaceName string

@description('The location of the openai workspace')
param location string

@description('The managed identity id')
param managedIdentityId string

@description('The managed identity pricial id')
param managedIdentityPrincipalId string

@description('The network connection approver role definition id.')
var networkConnectionApproverRoleDefinitionId = 'b556d68e-0be0-4f35-a333-ad7ee1ce17ea'

resource workspace 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: workspaceName
  location: location
  kind: 'OpenAI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    customSubDomainName: workspaceName
  }
  sku: {
    name: 'S0'
  }
}

// resource connectionApproverAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(workspace.id, managedIdentityPrincipalId, networkConnectionApproverRoleDefinitionId)
//   scope: workspace
//   properties: {
//     principalId: managedIdentityPrincipalId
//     roleDefinitionId: networkConnectionApproverRoleDefinitionId
//     principalType: 'ServicePrincipal'
//   }
// }

output workspaceId string = workspace.id
output workspaceName string = workspace.name
