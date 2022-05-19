param keyVaultName string='testkjnvkv'
param  tenantId string ='b8614a3-38fa-4410-81cc-2cff09afdee1'
param objectId string ='1c04e2ce-5286-48d8-bb77-601956b21af4'
param enabledForTemplateDeployment bool =true
param keysPermissions array =['all']
param secretsPermissions array =['all']
param vaultSku = 'Standard'
param enabledForDeployment bool =false
param enabledForTemplateDeployment bool
param enableVaultForVolumeEncryption bool =false
param secretName string ='test'
param secretValue securestring ='password'
     
resource keyvault 'Microsoft.KeyVault/vaults@2015-06-01' = {
    
      name: keyVaultName
     location: location
      
      properties: {
        "enabledForDeployment": enabledForDeployment
        "enabledForTemplateDeployment":enabledForTemplateDeployment
        "enabledForVolumeEncryption": enableVaultForVolumeEncryption
        "tenantId": tenantId
        "accessPolicies": [
          {
            "tenantId": tenantId
            "objectId": objectId
            "permissions": {
              "keys": keysPermissions
              "secrets": secretsPermissions
            }
          }
        ]
        sku: {
          name: vaultSku
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

