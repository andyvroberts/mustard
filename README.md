# Mustard
Azure Synapse Analytics configuration, settings and deploymnet.

## Deploy Prerequisites
In order to deploy from github actions, a resource group (RG) must already exist in the target Azure subscription.  Create this with the Azure CLI.  

``` 
az group create --name Mustard001 --location uksouth  
```

### App Registration
To connect to Azure from github, we will use the OIDC method by creating an AAD (Entra) Application. 
```
az ad app create --display-name MustardSynDeploy
```
From the JSON output, save the appId and id (object id).  
```
application_appid=$(az ad app list --display-name MustardSynDeploy --query '[].appId' -o tsv)
application_objectid=$(az ad app list --display-name MustardSynDeploy --query '[].id' -o tsv)
```  

### App Service Principal
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

### RBAC Role Assignment
Then make the RBAC contributor role assignment to the identity of the Application, for the Resource Group.
```
az role assignment create --role contributor --subscription $az_subid --assignee-object-id  $assignee_objectid --assignee-principal-type ServicePrincipal --scope subscriptions/$az_subid/resourceGroups/Mustard001/
```

### Azure Credential for Github
Finally, create an identity credential (a token for github to authenticate with Microsoft).  
Add the JSON configuration file for the credential in a file called _github-deploy-creds.json_  
```
{
    "name": "MustardDeployCred",
    "issuer": "https://token.actions.githubusercontent.com/",
    "subject": "repo:andyvroberts/mustard:ref:refs/heads/main",
    "description": "Synapse Deploy Credential",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
```
Note: If you want to connect the crediential to an Environment rather than a branch, then change this line:  
```
"subject": "repo:andyvroberts/mustard:environment:Production",
```
Execute the CLI command that uses the configuration:  
```
az ad app federated-credential create --id $application_objectid --parameters github-deploy-creds.json
``````  
  
### Portal Locations
In the Azure Portal, you can view the Application from:  
Microsoft Entra Id > App Registrations > the "all applications" tab.  

In the Azure Portal, you can view the Service Principal from:  
Microsoft Entra Id > Enterprise Applications > remove filter 'Enterprise Applications 'and search for the app name.  

In the Azure Portal, you can view the role assignments from the resource the role is assigned to:  
Resource Groups > Mustard001 > Access Control (IAM) > 'Role Assignments' tab

In the Azure Portal, you can view the github credential file from:  
Microsoft Entra Id > App Registrations > the "all applications" tab > click on "MustardSynDeploy" > certificates & secrets > in the "federated credentials" tab, click on "MustardDeployCred"   

### Github Secrets
In your github repo secrets, save these new _action_ secret values:
- AZURE_CLIENT_ID = $application_appid
- AZURE_TENANT_ID = $az_tenantid
- AZURE_SUBSCRIPTION_ID = $subid





az rest --method POST --uri 'https://graph.microsoft.com/beta/applications/$application_objectid/federatedIdentityCredentials' --body '{"name":"SynDeployCred2","issuer":"https://token.actions.githubusercontent.com","subject":"repo:andyvroberts/mustard:ref:refs/heads/main","description":"Second github credential test","audiences":["api://AzureADTokenExchange"]}'