param function_app_name string
param appservice_plan_name string
param app_insights_name string

param location string = resourceGroup().location
param storageprefix string
var storagAccountename = '${storageprefix}stg${uniqueString(resourceGroup().id)}'
var unique_function_name = '${function_app_name}-${uniqueString(resourceGroup().id)}'


resource storage_account 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storagAccountename
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
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource function_app 'Microsoft.Web/sites@2020-12-01' = {
  name: unique_function_name
  location: location
  kind: 'functionapp'
  dependsOn: [
    [storage_account]
    [appservice_plan]
    [app_insights]
  ]
  properties: {
    serverFarmId: appservice_plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value:'DefaultEndpointsProtocol=https;AccountName=${storage_account.name};AccountKey=${listKeys(storage_account.id, storage_account.apiVersion).keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(app_insights.id, '2015-05-01').InstrumentationKey
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: 'file/from/build'
        }
      ]
    }
  }
}
