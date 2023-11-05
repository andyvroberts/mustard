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

