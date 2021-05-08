
@minLength(3)
@maxLength(6)
param namePrefix string

param addressPrefixes array = [
  '10.0.0.0/24'
]

@allowed( [
  'eastus'
  'westus'
  'westeurope'
  'northeurope'
])
param location string 

var storageKind = 'StorageV2'
var vNetName = '${toUpper(namePrefix)}-VNET-${toUpper(uniqueString(resourceGroup().id))}'

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
  
  }
}

output vnetId string = vnet.id
output vnetAddressPrefixes array = vnet.properties.addressSpace.addressPrefixes

