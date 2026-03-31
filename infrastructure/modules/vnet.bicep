@description('The vnetNames')
param vnetName string

@description('The locations.')
param location string

//Todo: Use better ranges
@description('The address space of the vnet')
var addressSpace = '10.0.0.0/20'

@description('The address space of the AzureBastionSubnet')
var addressSpaceAzureBastionSubnet = '10.0.0.0/26'

@description('The address space of the jumphost subnet')
var addressSpaceJumphostSubnet = '10.0.4.0/22'

@description('The address space of the endpoint subnet')
var addressSpaceEndpointsSubnet = '10.0.8.0/22'

resource jumphostNsg 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: '${vnetName}-jumphost-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'DenyInternetInbound'
        properties: {
          priority: 4000
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowBastionRDP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource endpointsNsg 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: '${vnetName}-endpoints-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'DenyInternetInbound'
        properties: {
          priority: 4000
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

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
        name: 'jumphost'
        properties: {
          addressPrefix: addressSpaceJumphostSubnet
          networkSecurityGroup: {
            id: jumphostNsg.id
          }
        }
      }
      {
        name: 'endpoints'
        properties: {
          addressPrefix: addressSpaceEndpointsSubnet
          networkSecurityGroup: {
            id: endpointsNsg.id
          }
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
  jumphost: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'jumphost')
  endpoints: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'endpoints')
  AzureBastionSubnet: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'AzureBastionSubnet')
}

output subnetAddressSpaces object = {
  AzureBastionSubnet: vnet.properties.subnets[0].properties.addressPrefix
  jumphost: vnet.properties.subnets[1].properties.addressPrefix
  endpoints: vnet.properties.subnets[2].properties.addressPrefix
}
