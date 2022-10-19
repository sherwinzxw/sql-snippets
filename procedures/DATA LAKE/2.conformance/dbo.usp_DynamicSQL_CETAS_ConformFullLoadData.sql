CREATE OR ALTER PROCEDURE dbo.usp_DynamicSQL_CETAS_ConformFullLoadData
    @SchemaName VARCHAR(255),
    @TableName VARCHAR(255)
AS 

DECLARE @SQL VARCHAR(MAX) = 
CONCAT(
    'IF OBJECT_ID(N'''+ @SchemaName + '.' + @TableName + ''') IS NOT NULL ' +
    'BEGIN DROP EXTERNAL TABLE ' + @SchemaName +'.' + @TableName + ' END; ' +
    'CREATE EXTERNAL TABLE ' + @SchemaName + '.' + @TableName +' WITH (
        LOCATION = ''transactional/source_system_name/' + @TableName + '''
        ,DATA_SOURCE = [conformance_data_lake_storage_account]
        ,FILE_FORMAT = [SynapseParquetFormat]
    )  
    AS SELECT * FROM landing.', @SchemaName, '.' ,@TableName);
EXEC (@SQL)
