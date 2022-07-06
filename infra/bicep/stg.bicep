
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string
param location string = resourceGroup().location
param storageprefix string //from main

var storagAccountename = '${storageprefix}stg${uniqueString(resourceGroup().id)}'

// resource definition
resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storagAccountename
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
  output stgaccountid string = StorageAccount.id
  output stgaccountname string = StorageAccount.name
  output stgaccountapiversion string = StorageAccount.apiVersion
