param keyVaultName string
param  tenantId string
param objectId string 
param enabledForTemplateDeployment bool
param secretName string
param secretValue securestring 
     
resource keyvault 'Microsoft.KeyVault/vaults@2015-06-01' = {
    
      name: keyVaultName
     location: location
      
      properties: {
       
        enabledForTemplateDeployment:enabledForTemplateDeployment
       
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
    
   resource keyvaultaccesspolicy 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
           parent:keyvault
           name:secretName
            dependsOn: [
                keyVaultName
            ]
            properties: {
                value: secretValue
            }
            
        
    }

