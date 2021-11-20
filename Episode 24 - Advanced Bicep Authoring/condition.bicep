param deployZone bool

resource dnsZone 'Microsoft.Network/dnszones@2018-05-01' = if (deployZone) {
  name: 'myZone'
  location: 'global'
}


param zoneCount int

resource dnsZoneCount 'Microsoft.Network/dnszones@2018-05-01' = if (zoneCount > 0) {
  name: 'myZone2'
  location: 'global'
}



param replicateGlobally bool

resource myStorageAccount 'Microsoft.Storage/storageAccounts@2017-10-01' = {
  name: 'storageAccount'
  location: resourceGroup().location
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }
  }
  kind: 'StorageV2'
  sku: {
    name: replicateGlobally ? 'Standard_GRS' : 'Standard_LRS'
  }
}
