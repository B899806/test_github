
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string
param location string = resourceGroup().location
param storageprefix string //from main
param keyvaultname string
var secret = '${keyvaultname}-connstring'
param storagAccountename string = '${storageprefix}-stg'
var storageaccountkey = listKeys(StorageAccount.id, StorageAccount.apiVersion).keys[0].value

output storageaccountkey string = storageaccountkey

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

resource keyvault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyvaultname
}

resource keyvault_secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: secret
  parent:keyvault
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${StorageAccount.name};AccountKey=${listKeys(StorageAccount.id, StorageAccount.apiVersion).keys[0].value}'
  }
}

  output stgaccountid string = StorageAccount.id
  output stgaccountname string = StorageAccount.name
  output stgaccountapiversion string = StorageAccount.apiVersion
