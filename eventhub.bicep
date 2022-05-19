param namespace string='testeventhb'
param  location string ='eastus'
param skuname string ='basic'
param skucapacity string = 'basic'
  


resource keyvault 'Microsoft.EventHub/namespaces@2017-04-01' = {
    
      name: namespace
     location: location
       sku: {
      capacity: 1
      name: skuname
      tier:skucapacity
    }
    properties: {
      isAutoInflateEnabled: false

    }
}
      
     
