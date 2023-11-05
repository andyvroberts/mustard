# Synapse
## Azure Resource Providers
In order to use the REST API to generate synapse components, you must register the resource providers to your subscription.  
https://learn.microsoft.com/en-gb/azure/azure-resource-manager/management/resource-providers-and-types  

As Microsft state:  
When you create a resource through the portal, the resource provider is typically registered for you. When you deploy an Azure Resource Manager template or Bicep file, resource providers defined in the template are registered automatically. Sometimes, a resource in the template requires supporting resources that aren't in the template.  

For a Synapse Workspace, a supporting resource is *Microsoft.Sql* which we must register manually.  We will do this via the Azure CLI.  
```
az provider register --namespace Microsoft.Sql
```
To see what resources this gives you:  
```
az provider show --namespace Microsoft.Sql --query "resourceTypes[*].resourceType" --out table
```

## Synapse Workspace
workspace names must be globally unique so check first.  
```
az synapse workspace check-name --name smokesyndev001
```

### Synapse Workspace Connectivity Issues
If you have connectivity issues, run the microsoft diagnostic script from an elevated powershell.  
```
powershell.exe -executionpolicy Bypass -File "Test-AzureSynapse.ps1"
```