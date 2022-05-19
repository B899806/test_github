param namespace string
param  location string 
param skuname string 
param skucapacity string 
  


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
      
     
