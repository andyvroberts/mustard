-- ----------------------------------------------------------------------------
-- utf8 collation is needed if you are going to query CSV data by string columns
-- ----------------------------------------------------------------------------  
CREATE DATABASE DB1 COLLATE Latin1_General_100_BIN2_UTF8;  

USE DB1  

-- ----------------------------------------------------------------------------
-- optionally add a master key to encrypt all private keys and certificates within 
-- database DB1 (e.g. the data lake SAS tokens for scoped credentials, etc.).
-- ----------------------------------------------------------------------------  
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<strong_password>'  

-- ----------------------------------------------------------------------------
-- add a credential that will allow us to access the ADLS storage location.
-- ----------------------------------------------------------------------------  
CREATE/DROP DATABASE SCOPED CREDENTIAL sqlondemand  
WITH IDENTITY='SHARED ACCESS SIGNATURE',  
SECRET = '<get a sas token from the data lake ADLS account>'  

-- ----------------------------------------------------------------------------
-- create the data source using the scoped credential.
-- ----------------------------------------------------------------------------  
CREATE/DROP EXTERNAL DATA SOURCE LatestPrices WITH (
    LOCATION = 'https://yourdatalake.dfs.core.windows.net/warehouse/DB1',
    CREDENTIAL = sqlondemand
);  

-- ----------------------------------------------------------------------------
-- define a file format so a CSV file can be decoded and used.  
-- ---------------------------------------------------------------------------- 
CREATE EXTERNAL FILE FORMAT PricesInCsv
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS (
	FIELD_TERMINATOR = ',', 
	STRING_DELIMITER = '"', 
	ENCODING = 'UTF8', 
	PARSER_VERSION = '2.0'
    )
)  

-- ----------------------------------------------------------------------------
-- create the table in the dbo schema of DB1.
-- the file at the location must exist in the external data source location.
-- ----------------------------------------------------------------------------
CREATE EXTERNAL TABLE dbo.latest_prices 
( 
    row_key VARCHAR(38), 
    price NUMERIC(10), 
    price_date VARCHAR(24), 
    postcode VARCHAR(10), 
    property_type VARCHAR(5),
    new_build VARCHAR(5), 
    property_duration VARCHAR(5), 
    paon VARCHAR(256), 
    saon VARCHAR(256), 
    street VARCHAR(256), 
    locality VARCHAR(128),
    town VARCHAR(128), 
    district VARCHAR(128), 
    county VARCHAR(128), 
    ppd_category VARCHAR(5), 
    record_status VARCHAR(5)
)
WITH ( LOCATION =  'pp-monthly-update-new-version.csv',
       DATA_SOURCE = LatestPrices,
       FILE_FORMAT = PricesInCsv )


