param keyvaultname string
param location string

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

output keyvaultname string = keyvault.name
