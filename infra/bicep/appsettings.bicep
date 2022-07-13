param function_app_name string
param currentAppSettings object 
param appSettings object


resource siteconfig 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${function_app_name}/appsettings'
  properties: union(currentAppSettings, appSettings)
}
