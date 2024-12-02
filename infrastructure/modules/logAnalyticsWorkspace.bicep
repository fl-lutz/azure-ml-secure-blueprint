@description('The log analytics workspace name')
param logAnayticsWorkspaceName string

@description('The location for the environment')
param location string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnayticsWorkspaceName
  location: location
  tags: {
    service: 'App Factory'
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 10
    }
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceCustomerId object = {
  customerIds: logAnalyticsWorkspace.properties.customerId
}
output logAnalyticsWorkspacePrimarySharedKey object = {
  sharedKeys: logAnalyticsWorkspace.listKeys().primarySharedKey
}
