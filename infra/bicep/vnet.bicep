param virtualNetworks_name string = 'bicep_vn'
param location string = resourceGroup().location
var subnetName = 'bicep_vn'

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: virtualNetworks_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.10.0.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                'eastus2'
                'centralus'
              ]
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
  }
}

//output subnetid for endpoint for eventhubnamespace
output subnetIdForEndpoint string = virtualNetworks.properties.subnets[0].id
