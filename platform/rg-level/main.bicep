param azTags object
param synapseName string
param azLocation string
param dataLakeUrlFormat string
param dataLakeName string
param dataLakeRgName string
param warehouseContainerName string
//param bscContainerName string
param dataVaultName string
param adminUserSecretName string
param adminUserPasswordSecretName string
param ipAddress string

param rgName string = resourceGroup().name

// read the mandatory workspace db username and password
resource lakeVault 'Microsoft.KeyVault/vaults@2016-10-01' existing = {
  scope: resourceGroup(dataLakeRgName)
  name: dataVaultName
}

// create the synapse workspace
module synapse 'workspace.bicep' = {
  name: 'synapseModule'
  scope: resourceGroup()
  params: {
    azTags: azTags
    synapseName: synapseName
    azLocation: azLocation
    dataLakeUrlFormat: dataLakeUrlFormat
    dataLakeName: dataLakeName
    dataLakeFilesystemName: warehouseContainerName
    synapseAdminUser: lakeVault.getSecret(adminUserSecretName)
    synapseAdminUserPassword: lakeVault.getSecret(adminUserPasswordSecretName)
    rgName: rgName
    ipAddress: ipAddress
  }
}

