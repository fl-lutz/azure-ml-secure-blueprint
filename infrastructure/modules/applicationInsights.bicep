@description('The application insights name.')
param applicationInsightsName string

@description('The location')
param location string

@description('The main location log analytics workspace id.')
param logAnalyticsWorkspaceId string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

output applicationInsightsId string = applicationInsights.id
