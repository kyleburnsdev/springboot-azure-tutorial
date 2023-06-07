param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
param sku string = 'B1' // The SKU of App Service Plan
param linuxFxVersion string = 'JAVA|17-java17' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources
param releaseAnnotationGuid string = newGuid()
param releaseAnnotationDateStamp string = utcNow('yyyy-MM-ddTHH:mm:ss')

// resource names derived from resource group id to ensure uniqueness
var appServicePlanName = toLower('${webAppName}-plan')
var webSiteName = toLower('${webAppName}-web')
var workspaceName = toLower('${webAppName}-law')
var applicationInsightsName = toLower('${webAppName}-ai')
var keyvaultName = toLower('${webAppName}-kv')
var dbName = toLower('${webAppName}-psql')
var cacheName = toLower('${webAppName}-cache')

var dbHostName = '${dbName}.postgres.database.azure.com'
var cacheHostName = '${cacheName}.redis.cache.windows.net'

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  properties:{
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  tags: {
    displayName: 'AppInsight'
    ProjectName: webAppName
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspace.id
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: sku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      healthCheckPath: '/actuator/health'
    }
  }
}

resource symbolicname 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: appService
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
    ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    XDT_MicrosoftApplicationInsights_Java: '1'
    MY_SECRET_VALUE: '@Microsoft.KeyVault(VaultName=${keyvault.name};SecretName=mysecret)'
    SPRING_PROFILES_ACTIVE: 'cloud'
    POSTGRES_DB: 'postgres'
    POSTGRES_HOSTNAME: dbHostName
    POSTGRES_USER: webSiteName
    REDIS_HOSTNAME: cacheHostName
    REDIS_PORT: '6380'
    REDIS_PASSWORD: '@Microsoft.KeyVault(VaultName=${keyvault.name};SecretName=redisPassword)'
  }
}

resource appServiceSiteExtension 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: appService
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Warning'
      }
    }
    httpLogs: {
      fileSystem: {
        retentionInMb: 40
        enabled: true
      }
    }
    failedRequestsTracing: {
      enabled: true
    }
    detailedErrorMessages: {
      enabled: true
    }
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyvaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies:[
      {
        objectId: appService.identity.principalId
        permissions: {
          keys: [
            'list'
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'mysecret'
  parent: keyvault
  properties: {
    contentType: 'text/plain'
    value: 'replace me'
  }
}

resource redisPassSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'redisPassword'
  parent: keyvault
  properties: {
    contentType: 'text/plain'
    value: cache.listKeys().primaryKey
  }
}

resource cache 'Microsoft.Cache/redis@2022-06-01' = {
  name: cacheName
  location: location
  properties: {
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 1
    }
  }
}

resource db 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: dbName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    createMode: 'Default'
    version: '14'
    administratorLogin: ''
    administratorLoginPassword: null
    network: null
    availabilityZone: ''
    storage: {
      storageSizeGB: 32
    }
    dataEncryption: null
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: subscription().tenantId
    }
  }  
  
  resource firewallAzure 'firewallRules' = {
    name: 'allow-all-azure-internal-IPs'
    properties: {
        startIpAddress: '0.0.0.0'
        endIpAddress: '0.0.0.0'
    }
  }
}

output websiteName string = appService.name
output websiteIdentity string = appService.identity.principalId
output postgreSqlResourceName string = db.name
output applicationInsightsApplicationId string = applicationInsights.properties.ApplicationId
output applicationInsightsApiAppId string = applicationInsights.properties.AppId
output releaseAnnotationId string = releaseAnnotationGuid
output releaseAnnotationDate string = releaseAnnotationDateStamp
