@description('The name of the public ip')
param publicIpName string

@description('The location of the public ip')
param location string

@description('The public ip allocation method')
@allowed([
  'Dynamic'
  'Static'
])
param publicIpAllocationMethod string

@description('The public ip sku')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string

resource pip 'Microsoft.Network/publicIPAddresses@2024-03-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
}

output publicIpName string = pip.name
output publicIpId string = pip.id
