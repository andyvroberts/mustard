# Mustard
Azure Synapse Analytics configuration, settings and deploymnet.

## Deploy Prerequisites
In order to deploy from github actions, a resource group (RG) must already exist in the target Azure subscription.  Create this with the Azure CLI.  

``` 
az group create --name Mustard001 --location uksouth  
```

To connect to Azure from github, we will use the OIDC method by creating an AAD Application. 
```
az ad app create --display-name MustardSynDeploy
```
From the JSON output, save the appId and id (object id).  
```
application_appid=$(az ad app list --display-name MustardSynDeploy --query '[].appId' -o tsv)
application_objectid=$(az ad app list --display-name MustardSynDeploy --query '[].id' -o tsv)
```  

Next, create a service principal for the application.  
```
az ad sp create --id $application_appid
```
From the JSON output, save the object id.
```
assignee_objectid=$(az ad sp list --display-name MustardSynDeploy --query '[].id' -o tsv)
```

Before the assigning an RBAC permission, we need to also know the tenant and subscription id's of our application.  These are not automtically present in any of the JSON outputs so far, so query for them from the AZ Account from which you are logged in.  
```
az_tenantid=$(az account show --query tenantId -o tsv)
az_subid=$(az account show --query id -o tsv)
```

Then make the RBAC contributor role assignment to the identity of the Application, for the Resource Group.
```
az role assignment create --role contributor --subscription $az_subid --assignee-object-id  $assignee_objectid --assignee-principal-type ServicePrincipal --scope subscriptions/$az_subid/resourceGroups/Mustard001/
```

Finally, 

In the Azure Portal, you can view the Application from:  
Microsoft Entra Id > App Registration > the "all applications" tab.  

In the Azure Portal, you can view the Service Principal from:  
Microsoft Entra Id > Enterprise Applications > remove filter 'Enterprise Applications 'and search for the app name.  


In the Azure Portal, you can view the role assignments from the resource the role is assigned to:  
Resource Groups > Mustard001 > Access Control (IAM) > 'Role Assignments' tab



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



