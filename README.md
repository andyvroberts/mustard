# Mustard
Azure Synapse Analytics configuration, settings and deploymnet.

## Deploy Prerequisites
In order to deploy from github actions, a resource group (RG) must already exist in the target Azure subscription.  Create this with the Azure CLI.  

``` 
az group create --name Mustard001 --location uksouth  
```

The group requires a service principal with contributor RBAC, in order to deploy the resources within from github to this RG.  
NOTE: If running this on git bash, ensure you make this env setting:  
```
export MSYS_NO_PATHCONV=1
```
Then run the SP create.  
```
subid=$(az account show --query id -o tsv)

az ad sp create-for-rbac --name SynDeployGH --role contributor --scopes /subscriptions/$subid/resourceGroups/Mustard001 --sdk-auth
```

In your github repo secrets, save these new _action_ secret values:
- AZURE_CREDENTIALS = the entire SP create-for-rbac command JSON result
- AZURE_RG = Mustard001
- AZURE_SUBSCRIPTION = the subscription ID used to create the SP (content of $subid)



