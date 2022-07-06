param keyvaultname string
param location string
param secretname string
param tenantid string

resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyvaultname
  location: location
  properties:{
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    tenantId: tenantid
  }
} 

resource secrets 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secretname
  parent:keyvault
  properties: {
    value: 'sastoken'
    attributes: {
      enabled: true
    }
  }
}

output keyvaultname string = keyvault.name
output secretname string = secrets.name
