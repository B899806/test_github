// scope
targetScope = 'resourceGroup'

// parameters
param storageAccountType string
param location string
param storagename string


// resource definition
resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storagename
  location: location
 
  kind: 'StorageV2'
  sku: {
    name: storageAccountType
  }
  properties: {

  allowBlobPublicAccess: false

}

  

  
}


