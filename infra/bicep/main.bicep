// =========== main.bicep ===========

// Setting target scope
targetScope = 'resourceGroup'

param location string = 'eastus2'
param prefix string = 'projectname' // add prefix you want add to resources
param rgname string = 'Bhoomika_GitAR'
param keyvaultname string = 'keyvault-proj'
param vnetid string = '' // provide vnet if for network access

//param for function app
param function_app_name string = 'mjisaak-bicep-func'
param appservice_plan_name string = 'mjisaak-bicep-asp'
param app_insights_name string = 'mjisaak-bicep-appinsights'
param storageprefix string = prefix

output stgaccountid string = stg.outputs.stgaccountid
output stgaccountname string = stg.outputs.stgaccountname
output stgaccountapiversion string = stg.outputs.stgaccountapiversion


/*resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgname
  location: location
}*/

module keyvault 'kv.bicep' = {
  scope: az.resourceGroup(rgname)
  name: 'keyvaultDeployment'
  params: {
    location: location
    secretname: 'keyvaultname-secret'
    tenantid: ''
    keyvaultname: keyvaultname
  }
}

module stg './stg.bicep' = {
  name: 'storageDeployment'
  scope: az.resourceGroup(rgname)    // Deployed in the scope of resource group we created above
  params: {
      location: location
      storageprefix: prefix
      storageAccountType: 'Standard_GRS'
  }
}

module appfunction './appfunction.bicep' = {
  name: 'appfunctionDeployment'
  scope: az.resourceGroup(rgname)    // Deployed in the scope of resource group we created above
   params:{
    storageprefix: storageprefix
    location:location
    app_insights_name: app_insights_name
    appservice_plan_name: appservice_plan_name
    function_app_name: function_app_name
   }
  //params: {
      //location: location
      //azAppFunctionPrefix: prefix
      //storageAccountId: stg.outputs.stgaccountid
      //storageAccountName: stg.outputs.stgaccountname
      //storageAccountapiversion:stg.outputs.stgaccountapiversion
      //eventhubname: eventhub.outputs.eventHubName
      //eventhubnamespaceconnection: eventhub.outputs.eventHubNamespaceConnectionString
  //}
}


module databricksWS './db.bicep' = {
  name: 'databricksWSDeployment'
  scope: az.resourceGroup(rgname)    // Deployed in the scope of resource group we created above
  params: {
    location: location
    DataBricksWSprefix: prefix
    pricingTier: 'premium'
    disablePublicIp: false
}
}

module eventhub './eventhub.bicep' = {
  name: 'EventHubDeployment'
  scope: az.resourceGroup(rgname)    // Deployed in the scope of resource group we created above
  params: {
      location: location
      EventHubPrefix: prefix
      VNetsubnetIdForEndpoint: vnetid
  }
}
