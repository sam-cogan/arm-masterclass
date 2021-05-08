
param supportsHttpsTrafficOnly bool = true

@minLength(3)
@maxLength(24)
param storageAccountName string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param storageSKU string = 'Standard_LRS'


param location string {
  allowed:[
    'eastus'
    'westus'
    'westeurope'
    'northeurope'
  ]
}

var storageKind = 'StorageV2'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName 
  location: location
  sku: {
    name: storageSKU
  }
  kind: storageKind
  properties: {
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
  }
}

output storageAccountId string = stg.id
output storageAccountHttpsEnabled bool = stg.properties.supportsHttpsTrafficOnly
output storageEndpoint object = stg.properties.primaryEndpoints
