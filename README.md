# Mustard
Azure Synapse Analytics configuration, settings and deploy from Github.   

Last Deployment:
![Build Status](https://github.com/andyvroberts/mustard/actions/workflows/deploy.yaml/badge.svg)

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
### Azure Credential for Github (Working)
Finally, create an identity credential (a token for github to authenticate with Microsoft).  Using the MS beta graph API to create this was the only method by which a working credential could be configured.  

Because the $application_objectid below, is in a string, substitute the actual id value into the command.  
```
az rest --method POST --uri 'https://graph.microsoft.com/beta/applications/$application_objectid/federatedIdentityCredentials' --body '{"name":"SynDeployCred2","issuer":"https://token.actions.githubusercontent.com","subject":"repo:andyvroberts/mustard:ref:refs/heads/main","description":"Working Synapse Deploy Credential","audiences":["api://AzureADTokenExchange"]}'
```

### Azure Service Principal with Deployment Grants 
We need deploy priviliges if we are making assignments to other Resource Groups 
1. KeyVault grants
3. Storage role assignment grants
3. Storage Account grants
  
For example:  
https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/key-vault-parameter?tabs=azure-cli#grant-deployment-access-to-the-secrets  
For using KeyVaults that are not in the Synapse resource group, the app Service Principal must be granted the bespoke *Microsoft.KeyVault/vaults/deploy/action* permission at the subscription level.  This permission is not available by individual Vaults.      
Note: this is needed here as our SP should NOT be granted contributor or owner on the KeyVault.  Follow the web page instructions.  
  
Create the custom role definition deployrole.json file, substituting your subscription ID at the bottom: 
```
{
  "Name": "Deployment Principal",
  "IsCustom": true,
  "Description": "Lets you deploy a resources without having contributor RBAC in another Resource Group.",
  "Actions": [
    "Microsoft.KeyVault/vaults/deploy/action",
    "Microsoft.Resources/deployments/write",
    "Microsoft.Storage/storageAccounts/blobServices/write"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/00000000-0000-0000-0000-000000000000"
  ]
}
```
Then add the role to your subscription using the CLI:  
```
az role definition create --role-definition kvrole.json
```
Finally, add the role assignment to the SP, substituting the subscription id and making sure that the resource group is the one which contains the resources being granted:      
```
az role assignment create \
  --role "Deployment Principal" \
  --scope /subscriptions/<subscription_id>/resourceGroups/NrgdxData \
  --assignee-object-id $assignee_objectid \
  --assignee-principal-type ServicePrincipal
```

### Azure Credential for Github (Not Working)
To create an identity credential (a token for github to authenticate with Microsoft) using the CLI command:  
Add the JSON configuration file for the credential in a file called _github-deploy-creds.json_  
```
{
    "name": "MustardDeployCred",
    "issuer": "https://token.actions.githubusercontent.com/",
    "subject": "repo:andyvroberts/mustard:ref:refs/heads/main",
    "description": "Non-working Synapse Deploy Credential",
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
Note: Even though using this method produces *identical* Azure Portal credential details for the app registration as the beta graph api, this method always results in github logon error "Error: AADSTS700211: No matching federated identity record found for presented assertion issuer 'https://token.actions.githubusercontent.com'."
  
### Portal Locations
In the Azure Portal, you can view the Application from:  
Microsoft Entra Id > App Registrations > the "all applications" tab.  

In the Azure Portal, you can view the Service Principal from:  
Microsoft Entra Id > Enterprise Applications > remove filter 'Enterprise Applications 'and search for the app name.  

In the Azure Portal, you can view the role assignments from the resource the role is assigned to:  
Resource Groups > Mustard001 > Access Control (IAM) > 'Role Assignments' tab

In the Azure Portal, you can view the github credential file from:  
Microsoft Entra Id > App Registrations > the "all applications" tab > click on "MustardSynDeploy" > certificates & secrets > in the "federated credentials" tab, click on "MustardDeployCred"     

In the Azure Portal, you can view custom role definitions from:  
Subscription > Access Control (IAM) > "Roles" tab > search for 'Key Vault resource manager template deployment operator'  

### Github Secrets
In your github repo secrets, save these new _action_ secret values:
- AZURE_CLIENT_ID = $application_appid
- AZURE_TENANT_ID = $az_tenantid
- AZURE_SUBSCRIPTION_ID = $subid
- AZURE_RG = Mustard001




