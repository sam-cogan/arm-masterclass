param storageAccountName string
param containerName string = 'logs'
param location string = resourceGroup().location

var tier= 'Standard'
var accessTier = 'Hot'

resource sa 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: tier
  }
  kind: 'StorageV2'
  properties: {
    accessTier: accessTier
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${sa.name}/default/${containerName}'
}

output containerPath string = '${sa.name}/default/${containerName}'