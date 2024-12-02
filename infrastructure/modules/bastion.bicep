@description('The name of the bastion')
param bastionName string

@description('The location')
param location string

@description('The subnet id')
param subnetId string

module pip './publicIp.bicep' = {
  name: '${bastionName}-pip'
  params: {
    publicIpName: '${bastionName}-pip'
    location: location
    publicIpSku: 'Standard'
    publicIpAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2024-03-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    enableFileCopy: true
    enableTunneling: true
    ipConfigurations: [
      {
        name: '${bastionName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.outputs.publicIpId
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}
