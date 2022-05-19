param appName string
param location string
param serviceplanName string
param serviceplanSkuName string
 
resource serviceplan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: serviceplanName
  location: location
  sku: {
    name: serviceplanSkuName
  }

  properties: {
       
       perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
      }
}

resource fapp 'Microsoft.Web/sites@2016-08-01' = {
  name: appName
  location: location
  kind:'functionapp'

identity:{
        type: 'SystemAssigned'
      }
  properties: {
        serverFarmId: serviceplan.id
       enabled: true
        clientAffinityEnabled: false
        httpsOnly: true
      }

}
   


   
