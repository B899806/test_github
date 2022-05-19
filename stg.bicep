param appName string
param location string
param serviceplanName string
param serviceplanSkuName string
 
resource serviceplan 'Microsoft.Web/serverfarms@2015-08-01' = {
  name: serviceplanName
  location: location
  sku: {
    name: serviceplanSkuName
  }

  "properties": {
        name":serviceplanName
        numberOfWorkers: 1
      }
}

resource fapp 'Microsoft.Web/sites@2016-08-01' = {
  name: AppName
  location: location
  kind:'functionapp'
dependsOn: [
  serviceplan
]
identity:{
        type: SystemAssigned
      }
  properties: {
        serverFarmId: resourceId('Microsoft.Web/serverfarms', serviceplanName)
        hostingEnvironment: ""
        clientAffinityEnabled: false
        siteConfig: {
          alwaysOn: true
        }
        httpsOnly: true
      }

}
   


   
