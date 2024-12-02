@description('The vnetNames')
param vnetName string

@description('The locations.')
param location string

//Todo: Use better ranges
@description('The address space of the vnet')
var addressSpace = '10.0.0.0/20'

@description('The address space of the AzureBastionSubnet')
var addressSpaceAzureBastionSubnet = '10.0.0.0/26'

@description('The address space of the deployment subnet')
var addressSpaceDeploymentSubnet = '10.0.4.0/22'

@description('The address space of the endpoint subnet')
var addressSpaceEndpointsSubnet = '10.0.8.0/22'

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      {
        name: 'deployment'
        properties: {
          addressPrefix: addressSpaceDeploymentSubnet
        }
      }
      {
        name: 'endpoints'
        properties: {
          addressPrefix: addressSpaceEndpointsSubnet
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: addressSpaceAzureBastionSubnet
        }
      }
    ]
  }
}

output virtualNetworkId string = vnet.id

output subnetVnetIds object = {
  deployment: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'deployment')
  endpoints: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'endpoints')
  AzureBastionSubnet: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'AzureBastionSubnet')
}

output subnetAddressSpaces object = {
  AzureBastionSubnet: vnet.properties.subnets[0].properties.addressPrefix
  deployment: vnet.properties.subnets[1].properties.addressPrefix
  endpoints: vnet.properties.subnets[2].properties.addressPrefix
}
