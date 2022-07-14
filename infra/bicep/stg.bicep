@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string
param location string
param unique_stgaacct_name string

// resource definition
resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: unique_stgaacct_name
  location: location
  
  kind: 'StorageV2'
  sku: {
    name: storageAccountType
  }
  properties: {
  allowBlobPublicAccess: false
  }
  tags: {
    displayName: 'Demostgaccount'
  }

}

output storageaccountId string = StorageAccount.id
output storageapiversion string = StorageAccount.apiVersion
