// =========== main.bicep ===========

// Setting target scope
targetScope = 'resourceGroup'

param location string = 'eastus2'
param prefix string = 'as' // add prefix you want add to resources
param rgname string = 'Bhoomika_GitAR'
param keyvaultname string = 'kv-allsc'

//param for function app
param function_app_name string = 'bicep-func'
param appservice_plan_name string = 'bicep-asp'
param app_insights_name string = 'bicep-appinsights'
param storageprefix string = prefix


module keyvault 'kv.bicep' = {
  scope: az.resourceGroup(rgname)
  name: 'keyvaultDeployment'
  params: {
    location: location
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
      keyvaultname:keyvault.name
  }
}

module appfunction './appfunction.bicep' = {
  name: 'appfunctionDeployment'
  scope: az.resourceGroup(rgname)    // Deployed in the scope of resource group we created above
   params:{
    storageAccountId:stg.outputs.stgaccountid
    storageAccountapiversion:stg.outputs.stgaccountapiversion
    storageprefix: storageprefix
    location:location
    app_insights_name: app_insights_name
    appservice_plan_name: appservice_plan_name
    function_app_name: function_app_name
    eventhubname:eventhub.outputs.eventHubName
    eventhubnamespaceconnection:eventhub.outputs.eventHubNamespaceConnectionString
   }
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

module vnet './vnet.bicep' = {
  name: 'vNetDeployment'
  scope: az.resourceGroup(rgname)    // Deployed in the scope of resource group we created above
  params: {
      location: location
  }
}

module eventhub './eventhub.bicep' = {
  name: 'EventHubDeployment'
  scope: az.resourceGroup(rgname)    // Deployed in the scope of resource group we created above
  params: {
      location: location
      EventHubPrefix: prefix
      VNetsubnetIdForEndpoint: vnet.outputs.subnetIdForEndpoint
  }
}
