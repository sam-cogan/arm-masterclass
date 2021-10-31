param storageAccountName string
param location string = resourceGroup().location

var tier = 'Standard'
var accessTier = 'Hot'
var containerName = 'logs'

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
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${sa.name}/default/${containerName}'
}

output accountName string = sa.name
output accountId string = sa.id
output logPath string = '${sa.name}/default/${containerName}'
