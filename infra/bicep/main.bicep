// =========== main.bicep ===========

// Setting target scope
targetScope = 'resourceGroup'

//General param for deployment
param location string
param prefix string // add prefix you want add to resources
param rgname string
param locationprefix string

//param for function app
param function_app_name string = 'bicep-func'
param appservice_plan_name string = 'bicep-asp'
param app_insights_name string = 'bicep-appinsights'
param unique_function_name string = '${prefix}-${function_app_name}-${locationprefix}'


//param for keyvault and secret
param keyvaultname string = 'kv-allsc'

//param for storage account
param storagAccountename string


module keyvault 'kv.bicep' = {
  scope: az.resourceGroup(rgname)
  name: 'keyvaultDeployment'
  params: {
    location: location
    keyvaultname: keyvaultname
    storagAccountename:storagAccountename
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
    storagAccountename:storagAccountename
    unique_function_name:unique_function_name
    location:location
    app_insights_name: app_insights_name
    appservice_plan_name: appservice_plan_name
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
