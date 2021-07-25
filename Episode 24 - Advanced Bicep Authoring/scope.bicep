targetScope = 'resourceGroup'

param otherResourceGroup string
param otherSubscriptionID string

// module deployed to different subscription and resource group
module exampleModule 'module.bicep' = {
  name: 'otherSubAndRG'
  scope: resourceGroup(otherSubscriptionID, otherResourceGroup)
}


module exampleModuleSub 'module.bicep' = {
  name: 'deployToSub'
  scope: subscription()
}

module exampleModuleTenant 'module.bicep' = {
  name: 'deployToTenant'
  scope: tenant()
}
