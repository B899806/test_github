param function_app_name string
param appservice_plan_name string
param app_insights_name string
param eventhubname string
param eventhubnamespaceconnection string
param skuname string = 'Y1'
param skutier string = 'Dynamic'
var AccountKey = '${listKeys(storage_account.id, storage_account.apiVersion).keys[0].value}'

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

resource storage_account 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountname
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}


resource function_app 'Microsoft.Web/sites@2022-03-01' = {
  name: unique_function_name
  location: location
  kind: 'functionapp'
  dependsOn: [
    [storage_account]
    [appservice_plan]
    [app_insights]
  ]
  properties: {
    enabled:true
    serverFarmId: appservice_plan.id
  }
}


module appSettings 'appSettings.bicep' = {
  name: 'Function-appSettings'
  params: {
    function_app_name: function_app_name
    currentAppSettings:  list('${function_app.id}/config/appsettings', '2020-12-01').properties //merge current settings
    appSettings: {

      WEBSITE_RUN_FROM_PACKAGE: './eventhubfunction/function.zip'
      APPINSIGHTS_INSTRUMENTATIONKEY: AppInsightsInstrumentationKey
      APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=${AppInsightsInstrumentationKey}'
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountname};EndpointSuffix=${environment().suffixes.storage};AccountKey=${AccountKey}'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      WEBSITE_CONTENTSHARE: toLower(storageAccountname)
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountname}'
      DiagnosticServices_EXTENSION_VERSION: '~4'
      EventHubName: eventhubname //from output of eventhub.bicep
      EventHubNSConnection: eventhubnamespaceconnection //from output of eventhub.bicep
      /*
      OutputStorage: 'DefaultEndpointsProtocol=https;AAccountName=${storageAccountName};AccountKey=${azStorageAccountAccessKey}'
      ContainerName: 'star-landing'
      */
    } 
  }
}
