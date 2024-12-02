targetScope = 'resourceGroup'

// ==================================================
// Parameters
// ==================================================
@description('The instance of the deployment')
param instance string

@description('The location of the deployment')
param location string

@description('The prefix for the deployment')
param prefix string

@description('The virtual machine admin password')
@secure()
param vmAdminPassword string = ''

@description('The timestamp of the deployment')
param timestamp string = utcNow()

// ==================================================
// Variables
// ==================================================
var prefixAlphanumeric = toLower(replace(prefix, '-', ''))

var formattedTimestamp = replace(replace(replace(timestamp, 'T', '-'), ':', '-'), 'Z', '')

// ==================================================
// Network
// ==================================================
module vnet './modules/vnet.bicep' = {
  name: 'vnet-${formattedTimestamp}'
  params: {
    vnetName: '${prefix}-vnet-${instance}'
    location: location
  }
}

// ==================================================
// Engineering Access
// ==================================================
module bastion './modules/bastion.bicep' = {
  name: 'bastion-${formattedTimestamp}'
  params: {
    bastionName: '${prefix}-bastion-${instance}'
    location: location
    subnetId: vnet.outputs.subnetVnetIds.AzureBastionSubnet
  }
}

module virtualMachine './modules/virtualMachine.bicep' = if (vmAdminPassword != '') {
  name: 'virtual_machine-${formattedTimestamp}'
  params: {
    virtualMachineName: '${prefix}-vm-${instance}'
    location: location
    subnetId: vnet.outputs.subnetVnetIds.deployment
    adminUsername: 'developer'
    adminPassword: vmAdminPassword
    vmSize: 'Standard_D4ads_v5'
  }
}

// ==================================================
// Logging
// ==================================================
module log_analytics_workspace './modules/logAnalyticsWorkspace.bicep' = {
  name: 'log_analytics_workspace-${formattedTimestamp}'
  params: {
    logAnayticsWorkspaceName: '${prefix}-law-${instance}'
    location: location
  }
}

module application_insights './modules/applicationInsights.bicep' = {
  name: 'application_insights-${formattedTimestamp}'
  params: {
    applicationInsightsName: '${prefix}-appinsights-${instance}'
    location: location
    logAnalyticsWorkspaceId: log_analytics_workspace.outputs.logAnalyticsWorkspaceId
  }
}

// ==================================================
// Container Registries
// ==================================================
module container_registry './modules/containerRegistry.bicep' = {
  name: 'container_registry-${formattedTimestamp}'
  params: {
    containerRegistryName: '${prefixAlphanumeric}crprivate${instance}'
    location: location
    sku: 'Premium'
    managedIdentityPrincipalId: managed_identity.outputs.managedIdentityPrincipalId
  }
}

module container_registry_private_endpoint './modules/privateEndpoint.bicep' = {
  name: 'container_registry_private_endpoint-${formattedTimestamp}'
  params: {
    privateEndpointName: '${prefix}-cr-pe-${instance}'
    location: location
    subnetId: vnet.outputs.subnetVnetIds.endpoints
    privateDnsZoneNames: ['privatelink.azurecr.io']
    vnetId: vnet.outputs.virtualNetworkId
    targetResourceId: container_registry.outputs.containerRegistryId
    targetResourceName: container_registry.outputs.containerRegistryName
    targetGroupIds: [
      'registry'
    ]
    targetResourceType: 'registry'
  }
}

// ==================================================
// Managed Identity
// ==================================================
module managed_identity './modules/managedIdentity.bicep' = {
  name: 'managed_identity-${formattedTimestamp}'
  params: {
    managedIdentityName: '${prefix}-mi-${instance}'
    location: location
  }
}

// ==================================================
// Storage Account
// ==================================================
module storage_account './modules/storageAccount.bicep' = {
  name: 'storage_account-${formattedTimestamp}'
  params: {
    storageName: '${prefixAlphanumeric}sa${instance}'
    location: location
    managedIdentityPrincipalId: managed_identity.outputs.managedIdentityPrincipalId
  }
}

module storage_account_blob_private_endpoint './modules/privateEndpoint.bicep' = {
  name: 'storage_account_blob_private_endpoint-${formattedTimestamp}'
  params: {
    privateEndpointName: '${prefix}-sa-blob-pe-${instance}'
    location: location
    subnetId: vnet.outputs.subnetVnetIds.endpoints
    #disable-next-line no-hardcoded-env-urls
    privateDnsZoneNames: ['privatelink.blob.core.windows.net']
    vnetId: vnet.outputs.virtualNetworkId
    targetResourceId: storage_account.outputs.storageAccountId
    targetResourceName: storage_account.outputs.storageAccountName
    targetGroupIds: [
      'blob'
    ]
    targetResourceType: 'storageaccount'
  }
}

module storage_account_file_private_endpoint './modules/privateEndpoint.bicep' = {
  name: 'storage_account_file_private_endpoint-${formattedTimestamp}'
  params: {
    privateEndpointName: '${prefix}-sa-file-pe-${instance}'
    location: location
    subnetId: vnet.outputs.subnetVnetIds.endpoints
    #disable-next-line no-hardcoded-env-urls
    privateDnsZoneNames: ['privatelink.file.core.windows.net']
    vnetId: vnet.outputs.virtualNetworkId
    targetResourceId: storage_account.outputs.storageAccountId
    targetResourceName: storage_account.outputs.storageAccountName
    targetGroupIds: [
      'file'
    ]
    targetResourceType: 'storageaccount'
  }
}

// ==================================================
// Key Vault
// ==================================================
module key_vault './modules/keyVault.bicep' = {
  name: 'key_vault-${formattedTimestamp}'
  params: {
    keyVaultName: '${prefix}-kv-3126-${instance}'
    location: location
    managedIdentityPrincipalId: managed_identity.outputs.managedIdentityPrincipalId
    publicNetworkAccess: 'Disabled'
  }
}

module key_vault_pe './modules/privateEndpoint.bicep' = {
  name: 'key_vault_pe-${formattedTimestamp}'
  params: {
    privateEndpointName: '${prefix}-kv-pe-${instance}'
    location: location
    subnetId: vnet.outputs.subnetVnetIds.endpoints
    privateDnsZoneNames: ['privatelink.vaultcore.azure.net']
    vnetId: vnet.outputs.virtualNetworkId
    targetResourceId: key_vault.outputs.keyVaultId
    targetResourceName: key_vault.outputs.keyVaultName
    targetGroupIds: [
      'vault'
    ]
    targetResourceType: 'keyvault'
  }
}

// ==================================================
// Open Ai Workspace
// ==================================================
module openai_workspace './modules/openAiWorkspace.bicep' = {
  name: 'openai_workspace-${formattedTimestamp}'
  params: {
    workspaceName: '${prefix}-azopenai-${instance}'
    location: location
    managedIdentityId: managed_identity.outputs.managedIdentityId
    managedIdentityPrincipalId: managed_identity.outputs.managedIdentityPrincipalId
  }
}

module openai_workspace_pe './modules/privateEndpoint.bicep' = {
  name: 'openai_workspace_pe-${formattedTimestamp}'
  params: {
    privateEndpointName: '${prefix}-azopenai-pe-${instance}'
    location: location
    subnetId: vnet.outputs.subnetVnetIds.endpoints
    privateDnsZoneNames: ['privatelink.openai.azure.com']
    vnetId: vnet.outputs.virtualNetworkId
    targetResourceId: openai_workspace.outputs.workspaceId
    targetResourceName: openai_workspace.outputs.workspaceName
    targetGroupIds: [
      'account'
    ]
    targetResourceType: 'account'
  }
}

// ==================================================
// Machine Learning Workspace
// ==================================================
module machine_learning_workspace './modules/machineLearningWorkspace.bicep' = {
  name: 'machine_learning_workspace-${formattedTimestamp}'
  params: {
    machineLearningWorkspaceName: '${prefix}-mlw-${instance}'
    location: location
    applicationInsightsId: application_insights.outputs.applicationInsightsId
    containerRegistryId: container_registry.outputs.containerRegistryId
    storageAccountId: storage_account.outputs.storageAccountId
    keyVaultId: key_vault.outputs.keyVaultId
    managedIdentityId: managed_identity.outputs.managedIdentityId
    openAiWorkspaceId: openai_workspace.outputs.workspaceId
  }
}

module machine_learning_workspace_pe './modules/privateEndpoint.bicep' = {
  name: 'machine_learning_workspace_pe-${formattedTimestamp}'
  params: {
    privateEndpointName: '${prefix}-mlw-pe-${instance}'
    location: location
    subnetId: vnet.outputs.subnetVnetIds.endpoints
    privateDnsZoneNames: ['privatelink.api.azureml.ms', 'privatelink.notebooks.azure.net']
    vnetId: vnet.outputs.virtualNetworkId
    targetResourceId: machine_learning_workspace.outputs.machineLearningWorkspaceId
    targetResourceName: machine_learning_workspace.outputs.machineLearningWorkspaceName
    targetGroupIds: [
      'amlworkspace'
    ]
    targetResourceType: 'amlworkspace'
  }
}
