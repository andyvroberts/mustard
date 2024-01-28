# Serverless SQL Pool
https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/best-practices-serverless-sql-pool  

## Database Creation
Optionally, create a master key that will be used to encrypt passwords and certificates.  
See the [SQL Server master key syntax](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-master-key-transact-sql?view=sql-server-ver16) documentation.  Ensure you save your master key in the project Key Vault.  

A scoped credential is used by a database to access data in external locations.  The credential can be a SAS token or a managed identity.  SAS takes precedence over identities if both are specified.  

The SAS key, if used must be for the ADLS container (or any parent folder) that will be accessed by the SQL database.  

An External Data Source provides a locational reference for external datasets that will be added as database tables.  

An External File Format specifies the properties of the data file from which an external database table will be defined.  
See the [Delimted Format Type](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-external-file-format-transact-sql?view=sql-server-ver16&tabs=delimited) documentation for all options regarding CSV files.  

Create an external table definition, based on the columns in your CSV file (or other file type).  For more details about the syntax and features such as partition pruning, see [the external tables documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables?tabs=hadoop).  
If required, you can create a custom schema to better organise many tables.  

## Open Rowset Queries
See [the open rowset documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-openrowset).  

## Diagrams

### Data Lake RBAC
<details>  
    <summary>ADLS Roles for Persona</summary>  

:::mermaid
flowchart TD
    contributor["`_storage blob data contributor_`"]
    reader["`_storage blob data reader_`"]
    engineer["Data Engineer"]
    architect["Data Architect"]
    principal["Synapse Managed Identity"]
    subgraph Create/Delete/Write/Read
    contributor
    end
    subgraph Read
    reader
    end
    contributor --> engineer
    contributor --> principal
    reader --> architect

:::

</details>  


### Access Control
<details>  
    <summary>Serverless SQL Pool Database Access</summary> 

</details>

:::mermaid
%%{init: 
{'theme':'forest'}
}%%
flowchart LR
    starting["Published Data Zone"]
    dbs["Database1.Table1
    Database2.View1
    Database3.View2"]

    subgraph serverless["Serverless SQL Pool"]
        dbs
    end

    starting---|Synapse\nManaged\nIdentity|serverless

:::

<br>  
<br>  


:::mermaid
%%{init: 
{'theme':'neutral'}
}%%

flowchart LR
    starting["Published Data Zone"]
    db1["Database One"]
    db2["Database Two"]

    subgraph serverless[" "]
        direction TB
            subgraph ad1["Azure AD Group One\n "]
            db1
            end
            subgraph ad2["Azure AD Group Two\n "]
            db2
            end
        db1~~~db2
    end

    starting-->|Synapse\nManaged\nIdentity|serverless
:::




{'themeVariables': { 'edgeLabelBackground': 'transparent'}}