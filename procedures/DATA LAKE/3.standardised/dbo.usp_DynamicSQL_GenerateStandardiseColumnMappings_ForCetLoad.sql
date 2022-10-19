USE standardised;
GO

CREATE OR ALTER PROCEDURE dbo.usp_DynamicSQL_GenerateStandardiseColumnMappings_ForCetLoad
    @ConformedSchemaName VARCHAR(255),
    @ConformedTableName VARCHAR(255),
    @TargetEntityBlobLocation VARCHAR(255)
AS
WITH CTE AS (
    SELECT
        *	
	FROM conformance.metadb.SchemaMappingControl
	WHERE ActiveFlag = 1
    AND SourceTableName = @ConformedTableName
	AND SourceTableSchemaName = @ConformedSchemaName
	AND TargetEntityBlobLocation = @TargetEntityBlobLocation
),
CTE_DDL AS (
    SELECT
        TargetEntityName,
        SourceColumnName  + ' AS  ' + TargetColumnName AS ColumnDefinition
    FROM
        CTE
)
,CTE_PRE_CREATE_DDL AS (
    SELECT
        TargetEntityName,
        STRING_AGG(CONVERT(NVARCHAR(max), ColumnDefinition), ',') AS CTE_DDL
    FROM
        CTE_DDL
    GROUP BY
        TargetEntityName
)
SELECT
    CTE_DDL AS COLUMN_MAPPINGS
FROM
    CTE_PRE_CREATE_DDL



--EXEC usp_DynamicSQL_SELECT_Generate_SDT_Entity_Column_Mappings_CET 'source_system_name', 'Person', 'S_CommAddress/Phone/Home'