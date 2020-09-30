param location string = resourceGroup().location
param functionAppName string
param cosmosAccountName string
param cosmosDatabaseName string
param cosmosContainerName string
param cosmosContainerPartitionKey string

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
    name: '${cosmosAccount.name}/${cosmosDb.name}/${cosmosContainerName}'
    properties: {
        resource: {
            id: cosmosContainerName
            indexingPolicy: {
                indexingMode: 'consistent'
                automatic: true
                includePaths: [
                    {
                        path: '/*'
                        indexes: [
                            {
                                kind: 'Range'
                                dataType: 'Number'
                                precision: -1
                            }
                            {
                                kind: 'Range'
                                dataType: 'String'
                                precision: -1
                            }
                        ]
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