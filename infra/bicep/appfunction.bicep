param function_app_name string
param appservice_plan_name string
param app_insights_name string
param eventhubname string
param eventhubnamespaceconnection string
param skuname string = 'Y1'
param skutier string = 'Dynamic'
param storageAccountId string
param storageAccountapiversion string

param location string = resourceGroup().location
param storageprefix string
var storageAccountname = '${storageprefix}stg${uniqueString(resourceGroup().id)}'
var unique_function_name = '${function_app_name}-${uniqueString(resourceGroup().id)}'
var AppInsightsInstrumentationKey = app_insights.properties.InstrumentationKey

resource app_insights 'Microsoft.Insights/components@2015-05-01' = {
  name: app_insights_name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource appservice_plan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appservice_plan_name
  location: location
  sku: {
    name: skuname
    tier: skutier
  }
}

resource function_app 'Microsoft.Web/sites@2022-03-01' = {
  name: unique_function_name
  location: location
  kind: 'functionapp'
  dependsOn: [
    [appservice_plan]
    [app_insights]
  ]
  properties: {
    enabled:true
    serverFarmId: appservice_plan.id
    }
}

var StorageAccountAccessKey = listKeys(storageAccountId , storageAccountapiversion).keys[0].value //storage info from output in storage.bicep

resource appsettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'functionapp'
  parent: function_app
  properties:{
    WEBSITE_RUN_FROM_PACKAGE: './eventhubfunction/function.zip'
    APPINSIGHTS_INSTRUMENTATIONKEY: AppInsightsInstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=${AppInsightsInstrumentationKey}'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountname};EndpointSuffix=${environment().suffixes.storage};AccountKey=${StorageAccountAccessKey}'
    FUNCTIONS_EXTENSION_VERSION: '~3'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    WEBSITE_CONTENTSHARE: toLower(storageAccountname)
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountname};EndpointSuffix=${environment().suffixes.storage};AccountKey=${StorageAccountAccessKey}'
    DiagnosticServices_EXTENSION_VERSION: '~3'
    EventHubName: eventhubname //from output of eventhub.bicep
    EventHubNSConnection: eventhubnamespaceconnection //from output of eventhub.bicep
  }
}
