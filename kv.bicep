param keyVaultName string
param  tenantId string
param objectId string
param location string
resource keyvault 'Microsoft.KeyVault/vaults@2015-06-01' = {
   name: keyVaultName
  location: location
      properties: {
       enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
       tenantId: tenantId
       
        accessPolicies: [
          {
            tenantId: tenantId
            objectId: objectId
            permissions: {
              'get'
              'list'
            }
          }
        ]
        sku: {
          name: 'standard'
          family: 'A'
        }
        }
      }
  

