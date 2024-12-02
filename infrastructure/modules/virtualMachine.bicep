@description('The name of the virtual machine')
param virtualMachineName string

@description('The location')
param location string

@description('The virtual machine size')
param vmSize string

@description('The subnet id')
param subnetId string

@description('The admin username')
@secure()
param adminUsername string

@description('The admin password')
@secure()
param adminPassword string

module pip './publicIp.bicep' = {
  name: '${virtualMachineName}-pip'
  params: {
    publicIpName: '${virtualMachineName}-pip'
    location: location
    publicIpSku: 'Basic'
    publicIpAllocationMethod: 'Dynamic'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: '${virtualMachineName}-nsg'
  location: location
}

resource nic 'Microsoft.Network/networkInterfaces@2024-03-01' = {
  name: '${virtualMachineName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${virtualMachineName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pip.outputs.publicIpId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'dev-Vm'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-23h2-pro'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
