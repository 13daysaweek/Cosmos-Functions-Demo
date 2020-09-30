param location string = resourceGroup().location
param functionAppName string
param cosmosAccountName string
param cosmosDatabaseName string
param cosmosContainerName string
param cosmosContainerPartitionKey string

var functionHostName = '${functionAppName}.azurewebsites.net'
var functionScmHostName = '${functionAppName}.scm.azurewebsites.net'
var functionStorage = uniqueString(functionAppName)
var functionFarmName = '${functionAppName}-farm'
var appInsightsName: '${functionAppName}-insights'

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2020-06-01-preview' = {
    name: cosmosAccountName
    location: location
    tags: {
        defaultExperience: 'Core (SQL)'
        'hidden-cosmos-mmspecial': ''
        'CosmosAccountType': 'Non-Production'
    }
    kind: 'GlobalDocumentDB'
    identity: {
        type: 'None'
    }
    properties: {
        publicNetworkAccess: 'Enabled'
        enableAutomaticFailover: false
        enableMultipleWriteLocations: false
        isVirtualNetworkFilterEnabled: false
        virtualNetworkRules: [            
        ]
        disableKeyBasedMetadataWriteAccess: false
        enableFreeTier: false
        enableAnalyticalStorage: false
        createMode: 'Default'
        databaseAccountOfferType: 'Standard'
        consistencyPolicy: {
            defaultConsistencyLevel: 'Session'
            maxIntervalInSeconds: 5
            maxStalenessPrefix: 100
        }
        capabilities: [
            {
                name: 'EnableServerless'
            }
        ]
        ipRules: [            
        ]
        backupPolicy: {
            type: 'Periodic'
            periodicModeProperties: {
                backupIntervalInMinutes: 240
                backupRetentionIntervalInHours: 8
            }
        }
    }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-06-01-preview' = {
    name: '${cosmosAccount.name}/${cosmosDatabaseName}'
    properties: {
        resource: {
            id: cosmosDatabaseName
        }
    }
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2020-06-01-preview' = {
    name: '${cosmosDb.name}/${cosmosContainerName}'
    properties: {
        resource: {
            id: cosmosContainerName
            indexingPolicy: {
                indexingMode: 'consistent'
                automatic: true
                includedPaths: [
                    {
                        path: '/*'
                    }
                ]
                excludedPaths: [
                    {
                        path: '/"_etag"/?'
                    }
                ]
            }
            partitionKey: {
                paths: [
                    cosmosContainerPartitionKey
                ]
                kind: 'Hash'
            }
            conflictResolutionPolicy: {
                mode: 'LastWriterWins'
                conflictResolutionPath: '/_ts'
            }
        }
    }
}

resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: functionStorage
    location: location
    sku: {
        name: 'Standard_LRS'
        tier: 'Standard'
    }
    kind: 'Storage'
    properties: {
        networkAcls: {
            bypass: 'AzureServices'
            virtualNetworkRules: [                
            ]
            ipRules: [                
            ]
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
    }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
    name: '${storage.name}/default'
    sku: {
        name: 'Standard_LRS'
        tier: 'Standard'
    }
    properties: {
        cors: {
            corsRules: [                
            ]
        }
        deleteRetentionPolicy: {
            enabled: true
            days: 7
        }
    }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
    name: appInsightsName
    location: location
    kind: 'web'
    properties: {
        Application_Type: 'web'
        RetentionInDays: 90
        publicNetworkAccessForIngestion: 'Enabled'
        publicNetworkAccessForQuery: 'Enabled'
    }
}