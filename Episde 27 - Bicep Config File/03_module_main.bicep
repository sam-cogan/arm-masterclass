param prefix string

module stgacct 'br/modules:storage:v1' ={
  name: 'storageaccount'
  params: {
    storageAccountName: '${prefix}stg'
  }
}

output storageAccountName string = stgacct.outputs.accountName
