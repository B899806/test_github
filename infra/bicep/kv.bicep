param keyvaultname string
param location string
param storagAccountename string

var storageAccountId = StorageAccount.id
var storageAccountapiversion = StorageAccount.apiVersion
var StorageAccountAccessKey = listKeys(storageAccountId , storageAccountapiversion).keys[0].value //storage info from output in storage.bicep

resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyvaultname
  location: location
  properties:{
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls:{
      bypass:'AzureServices'
      defaultAction:'Allow'
    }
    accessPolicies: [
      {
      objectId: 'adb3c21a-ee9a-4066-9832-c7cbfa784d5e'
      tenantId: 'ab8614a3-38fa-4410-81cc-2cff09afdee1'
        permissions: {
          keys:['all']
          secrets:['all']
        }
      }
    ]
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    tenantId:'ab8614a3-38fa-4410-81cc-2cff09afdee1'
  }
}

resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: storagAccountename
}

resource keyvault_secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyvaultname}-stgconstring'
  properties: {
    attributes:{
      enabled:true
    }
    value: StorageAccountAccessKey
  }
}
