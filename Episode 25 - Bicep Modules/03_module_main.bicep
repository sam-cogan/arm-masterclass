param prefix string

module stgacct 'storage_module.bicep' ={
  name: 'storageaccount'
  params: {
    storageAccountName: '${prefix}stg'
  }
}

output storageAccountName string = stgacct.outputs.accountName
