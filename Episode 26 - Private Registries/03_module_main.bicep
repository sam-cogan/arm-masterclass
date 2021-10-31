param prefix string

module stgacct 'br:bicepreg.azurecr.io/bicep/modules/storage:v1' ={
  name: 'storageaccount'
  params: {
    storageAccountName: '${prefix}stg'
  }
}

output storageAccountName string = stgacct.outputs.accountName
