USE standardised;
GO
CREATE OR ALTER PROCEDURE dbo.usp_DynamicSQL_MapDataToStandardisedEntity_ForCetasLoad
    @ConformedSchemaName VARCHAR(255),
    @ConformedTableName VARCHAR(255),
    @ConformedTablePrimaryKeyName VARCHAR(255),
    @OriginSystemNameForLegacyKey VARCHAR(30),
    @TargetEntityName VARCHAR(255),
    @TargetEntityBlobLocation VARCHAR(255),
    @TargetColumnMappings VARCHAR(MAX)
AS 

DECLARE @SQL VARCHAR(MAX) = 
CONCAT(
    'IF OBJECT_ID(N''sdt.' + @TargetEntityName + ''') IS NOT NULL ' +
    'BEGIN DROP EXTERNAL TABLE sdt.' + @TargetEntityName + ' END; ' +
    'CREATE EXTERNAL TABLE sdt.' + @TargetEntityName +' WITH (
        LOCATION = ''transactional/sdt/' + @TargetEntityBlobLocation + '''
        ,DATA_SOURCE = [standardised_dojastriadatamigration1_dfs_core_windows_net]
        ,FILE_FORMAT = [SynapseParquetFormat]
    ) AS SELECT ' + 
    ' CONCAT(''' + @OriginSystemNameForLegacyKey + '-' + @ConformedTableName + '-' + ''',' + @ConformedTablePrimaryKeyName + ') AS LK,' + 
    @TargetColumnMappings + 
    ' FROM conformance.', @ConformedSchemaName, '.' ,@ConformedTableName);
EXEC(@SQL)

