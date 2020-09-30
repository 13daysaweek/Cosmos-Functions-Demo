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

resource functionFarm 'Microsoft.Web/serverFarms@2018-02-01' = {
    name: functionFarmName
    location: location
    sku: {
        name: 'Y1'
        tier: 'Dyanmic'
        size: 'Y1'
        family: 'Y'
        capacity: 0
    }
    kind: 'functionapp'
    properties: {
        perSiteScaling: false
        maximumElasticWorkerCount: 1
        isSpot: false
        reserved: true
        isXenon: false
        hyperV: false
        targetWorkerCount: 0
        targetWorkerSizeId: 0
    }
}

resource functionApp 'Microsoft.Web/sites@2018-11-01' = {
    name: functionAppName
    location: location
    kind: 'functionapp,linux'
    properties: {
        enabled: true
        hostNameSslStates: [
            {
                name: functionHostName
                sslState: 'Disabled'
                hostType: 'Standard'
            }
            {
                name: functionScmHostName
                sslState: 'Disabled'
                hostType: 'Repository'
            }
        ]
        serverFarmId: functionFarm.id
        reserved: true
        isXenon: false
        hyperV: false
        siteConfig: {
        }
        scmSiteAlsoStopped: false
        clientAffinityEnabled: false
        clientCertEnabled: false
        hostNamesDisabled: false
        containerSize: 1536
        dailyMemoryTimeQuota: 0
        httpsOnly: false
        redundancyMode: 'None'
    }
}

resource functionConfig 'Microsoft.Web/sites/config@2018-11-01' = {
    name: '${functionAppName}/web'
    location: location
    properties: {
        numberOfWorkers: -1
        defaultDocuments: [
            'Default.htm'
            'Default.html'
            'Default.asp'
            'index.htm'
            'index.html'
            'iisstart.htm'
            'default.aspx'
            'index.php'
        ]
        netFrameworkVersion: 'v4.0'
        linuxFxVersion: 'dotnet|3.1'
        requestTracingEnabled: false
        remoteDebuggingEnabled: false
        httpLoggingEnabled: false
        logsDirectorySizeLimit: 35
        publishingUsername: '$cmhtemp'
        azureStorageAccounts: {            
        }
        scmType: 'None'
        use32BitWorkerProcess: false
        webSocketsEnabled: false
        alwaysOn: false
        managedPipelineMode: 'Integrated'
        virtualApplications: [
            {
                virtualPath: '/'
                pysicalPath: 'site\\wwwroot'
                preloadEnabled: false
            }
        ]
        loadBalancing: 'LeastRequests'
        experiments: {
            rampUpRules: [                
            ]
        }
        autoHealEnabled: false
        cors: {
            allowedOrigins: [
                'https://functions.azure.com'
                'https://functions-staging.azure.com'
                'https://functions-next.azure.com'
            ]
            supportCredentials: false
        }
        localMySqlEnabled: false
        ipSecurityRestrictions: [
            {
                ipAddress: 'Any'
                action: 'Allow'
                priority: 1
                name: 'Allow all'
                description: 'Allow all access'
            }
        ]
        scmIpSecurityRestrictions: [
            {
                ipAddress: 'Any'
                action: 'Allow'
                priority: 1
                name: 'Allow all'
                description: 'Allow all access'
            }            
        ]
        scmIpSecurityRestrictionsUseMain: false
        http20Enabled: false
        minTlsVersion: '1.2'
        ftpsState: 'AllAllowed'
        reservedInstanceCount: 0
    }
}

resource hostBinding 'Microsoft.Web/sites/hostNameBindings@2018-11-01' = {
    name: '${functionAppName}/${functionHostName}'
    location: location
    properties: {
        siteName: functionAppName
        hostNameType: 'Verified'
    }
}