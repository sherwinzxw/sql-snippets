USE standardised;
GO
CREATE OR ALTER PROCEDURE dbo.usp_DynamicSQL_GenerateStandardiseColumnMappings_ForCetasLoad
    @ConformedSchemaName VARCHAR(255),
    @ConformedTableName VARCHAR(255)
AS
WITH CTE AS (
    SELECT
        *	
	FROM conformance.metadb.SchemaMappingControl
	WHERE ActiveFlag = 1
	AND SourceTableName = @ConformedTableName
	AND SourceTableSchemaName = @ConformedSchemaName
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
