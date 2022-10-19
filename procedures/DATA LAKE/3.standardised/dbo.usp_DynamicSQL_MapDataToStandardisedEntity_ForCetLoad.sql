USE standardised;
GO
CREATE OR ALTER PROCEDURE dbo.usp_DynamicSQL_MapDataToStandardisedEntity_ForCetLoad
    @ConformedSchemaName VARCHAR(255),
    @ConformedTableName VARCHAR(255),
    @ConformedTablePrimaryKeyName VARCHAR(255),
    @LegacyKeyPrefix VARCHAR(255),
    @LegacyKeySuffix VARCHAR(255) = NULL,
    @TargetEntityName VARCHAR(255),
    @TargetEntityBlobLocation VARCHAR(255),
    @TargetColumnMappings VARCHAR(MAX)
AS 

DECLARE @SQL_WITHOUT_SUFFIX VARCHAR(MAX) = 
CONCAT(
    'SELECT ' + 
    ' CONCAT(''' + @LegacyKeyPrefix + ''',LTRIM(RTRIM(' + @ConformedTablePrimaryKeyName + '))) AS LK,' + 
    @TargetColumnMappings + 
    ' FROM conformance.', @ConformedSchemaName, '.' ,@ConformedTableName);

DECLARE @SQL_WITH_SUFFIX VARCHAR(MAX) = 
CONCAT(
    'SELECT ' + 
    ' CONCAT(''' + @LegacyKeyPrefix + ''',LTRIM(RTRIM(' + @ConformedTablePrimaryKeyName + ')),''' + '-' + @LegacyKeySuffix + ''') AS LK,' + 
    @TargetColumnMappings + 
    ' FROM conformance.', @ConformedSchemaName, '.' ,@ConformedTableName, 
    ' WHERE ', @LegacyKeySuffix, ' IS NOT NULL');

IF @LegacyKeySuffix IS NULL
    BEGIN 
        EXEC (@SQL_WITHOUT_SUFFIX)
    END
ELSE 
    BEGIN
        EXEC (@SQL_WITH_SUFFIX)
    END

