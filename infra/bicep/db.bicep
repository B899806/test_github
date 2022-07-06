@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param disablePublicIp bool

@description('The name of the Azure Databricks workspace to create.')
param DataBricksWSprefix string 
var workspaceName  = '${DataBricksWSprefix}databricksWS'

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string

@description('Location for all resources.')
param location string = resourceGroup().location

//a managed resource group specific to Databricks workspace is automatically created
//The managed resource group must exist as this is where the cluster(s) will be created. 
//To ensure that nothing breaks them, they are placed in a separate resource group that has a super lock on it so you cannot modify anything in it.
var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'

resource ws 'Microsoft.Databricks/workspaces@2021-04-01-preview' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    authorizations: [
      {
        roleDefinitionId: ''
        principalId: ''
      }
    ]
    managedResourceGroupId: managedResourceGroup.id
    parameters: {
      enableNoPublicIp: {
        value: disablePublicIp
      }
    }
  }
}

//if the managed resource group for Databricks workspace was created then output the workspace properties
resource managedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  scope: subscription()
  name: managedResourceGroupName
}

output workspace object = ws.properties
