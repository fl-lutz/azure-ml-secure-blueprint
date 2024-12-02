@description('The private endpoint names')
param privateEndpointName string

@description('The locations')
param location string

@description('The subnet ids')
param subnetId string

@description('The private dns zone name')
param privateDnsZoneNames array

@description('The vnet id')
param vnetId string

@description('The target resource id')
param targetResourceId string

@description('The target resource name')
param targetResourceName string

@description('The target group ids')
param targetGroupIds array

@description('The target resource type')
@allowed([
  'registry'
  'storageaccount'
  'keyvault'
  'sites'
  'amlworkspace'
  'account'
])
param targetResourceType string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: targetResourceName
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: targetGroupIds
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = [
  for i in range(0, length(privateDnsZoneNames)): {
    name: privateDnsZoneNames[i]
    location: 'global'
  }
]

resource privateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [
  for i in range(0, length(privateDnsZoneNames)): {
    parent: privateDnsZones[i]
    name: '${privateDnsZones[i].name}-link'
    location: 'global'
    properties: {
      virtualNetwork: {
        id: vnetId
      }
      registrationEnabled: false
    }
  }
]

var privateDnsZoneConfig = [
  for i in range(0, length(privateDnsZoneNames)): {
    name: privateDnsZoneNames[i]
    properties: {
      privateDnsZoneId: privateDnsZones[i].id
    }
  }
]

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-03-01' = {
  parent: privateEndpoint
  name: targetResourceName
  properties: {
    privateDnsZoneConfigs: privateDnsZoneConfig
  }
}
