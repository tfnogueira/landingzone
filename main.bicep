targetScope = 'subscription'

@description('Nome do Resource Group')
param resourceGroupName string = 'rg-landingzone'

@description('Localização dos recursos')
param location string = 'eastus'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}
