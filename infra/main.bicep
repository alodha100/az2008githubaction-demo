targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

@description('Resource group name')
param resourceGroupName string = ''

@description('Port for the Flask application')
param PORT string = '5000'

@description('Flask environment')
param FLASK_ENV string = 'production'

// Generate a unique token for resource naming
var resourceToken = uniqueString(subscription().id, resourceGroup().id, location, environmentName)
var resourcePrefix = 'fsk'

// Create Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'az-${resourcePrefix}-${resourceToken}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
  tags: {
    'azd-env-name': environmentName
  }
}

// Create Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'az-${resourcePrefix}-${resourceToken}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
  tags: {
    'azd-env-name': environmentName
  }
}

// Create Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'az-${resourcePrefix}-${resourceToken}-kv'
  location: location
  properties: {
    enableRbacAuthorization: true
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
  tags: {
    'azd-env-name': environmentName
  }
}

// Create User-assigned Managed Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'az-${resourcePrefix}-${resourceToken}-id'
  location: location
  tags: {
    'azd-env-name': environmentName
  }
}

// Role assignment for Key Vault Secrets Officer
resource keyVaultSecretsOfficerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, userAssignedIdentity.id, 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') // Key Vault Secrets Officer
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Create App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'az-${resourcePrefix}-${resourceToken}-plan'
  location: location
  sku: {
    name: 'B1'
    capacity: 1
  }
  properties: {
    reserved: true // Required for Linux
  }
  tags: {
    'azd-env-name': environmentName
  }
}

// Create App Service
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: 'az-${resourcePrefix}-${resourceToken}-app'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      cors: {
        allowedOrigins: ['*']
        supportCredentials: false
      }
      appSettings: [
        {
          name: 'PORT'
          value: PORT
        }
        {
          name: 'FLASK_ENV'
          value: FLASK_ENV
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }
    httpsOnly: true
  }
  tags: {
    'azd-env-name': environmentName
    'azd-service-name': 'flask-webapp'
  }
}

// Create App Service diagnostic settings
resource appServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appService
  name: 'default'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Outputs
output RESOURCE_GROUP_ID string = resourceGroup().id
output APPLICATIONINSIGHTS_CONNECTION_STRING string = applicationInsights.properties.ConnectionString
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.properties.vaultUri
output AZURE_KEY_VAULT_NAME string = keyVault.name
output SERVICE_FLASK_WEBAPP_ENDPOINT_URL string = 'https://${appService.properties.defaultHostName}'
output SERVICE_FLASK_WEBAPP_NAME string = appService.name
