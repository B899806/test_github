param VNetsubnetIdForEndpoint string //from output of Vnet
param location string = resourceGroup().location
param EventHubPrefix string = '' //prefix to add for name

//variables for resource names with predefined prefis
var privateEndpointName  = '${EventHubPrefix}endpoint'
var namespaces_eventhubsns_name  = '${EventHubPrefix}eventhubsns${uniqueString(resourceGroup().id)}'//no hyphens allowed
var AuthorizationRuleName  = '${EventHubPrefix}AuthorizationRule'
var EventhubName  ='${EventHubPrefix}eventhub'
var privateLinkServiceConnectionName  = '${privateEndpointName}_${uniqueString(resourceGroup().id)}'
var fqdnName = '${EventHubPrefix}eventhubsns.servicebus.windows.net'


//eventhub namespace
resource namespaces_eventhubsns 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: namespaces_eventhubsns_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    disableLocalAuth: false
    zoneRedundant: true
    privateEndpointConnections: [
      {
        properties: {
          provisioningState: 'Succeeded'
        }
      }
    ]
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: true
  }
}



//endpoint
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id:  VNetsubnetIdForEndpoint
    }
    customDnsConfigs: [
      {
        fqdn:fqdnName
        ipAddresses: [
          '10.0.0.6'
        ]
      }
    ]
    privateLinkServiceConnections:[
      {
        name: privateLinkServiceConnectionName
        properties: {
          privateLinkServiceId: namespaces_eventhubsns.id
          groupIds: [
            'namespace'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    
  }
}



//Shared access policies in eventhub namespace
resource namespaces_eventhubsns_name_Auth 'Microsoft.EventHub/namespaces/AuthorizationRules@2021-11-01' = {
  parent: namespaces_eventhubsns
  name: AuthorizationRuleName
  properties: {
    rights: [
      'Send'
    ]
  }
}


//EventHub
resource namespaces_eventhubsns_eventhub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  parent: namespaces_eventhubsns
  name: EventhubName
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
    status: 'Active'
  }
}


resource namespaces_eventhubsns_name_default 'Microsoft.EventHub/namespaces/networkRuleSets@2021-11-01' = {
  parent: namespaces_eventhubsns
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
  }
}



//Shared access policies in EventHub
resource namespaces_eventhubsns_name_eventhub_PreviewDataPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  parent: namespaces_eventhubsns_eventhub
  name: 'PreviewDataPolicy'
  properties: {
    rights: [
      'Listen'
    ]
  }
 
}

resource namespaces_eventhubsns_name_eventhub_SendAndListen 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  parent: namespaces_eventhubsns_eventhub
  name: 'SendAndListen'
  properties: {
    rights: [
      'Manage'
      'Listen'
      'Send'
    ]
   }
}


//consumer groups
resource namespaces_eventhubsns_name_eventhub_Default 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  parent: namespaces_eventhubsns_eventhub
  name: '$Default'
}

resource namespaces_eventhubsns_name_eventhub_preview_data_consumer_group 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  parent: namespaces_eventhubsns_eventhub
  name: 'preview_data_consumer_group'
  properties: {}
}

resource namespaces_eventhubsns_name_eventhub__events_consumer_group 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  parent: namespaces_eventhubsns_eventhub
  name: '_events_consumer_group'
  properties: {}
}

 //TBD evethubnamespace should use secretkey for app setting's connection string of the azure function

 //Determine eventhub namespace connection string
var eventHubNamespaceConnectionString = listKeys(namespaces_eventhubsns_name_eventhub_SendAndListen.id, namespaces_eventhubsns_name_eventhub_SendAndListen.apiVersion).primaryConnectionString

// Output  variables for app function
output eventHubNamespaceConnectionString string = eventHubNamespaceConnectionString
output eventHubName string = EventhubName
