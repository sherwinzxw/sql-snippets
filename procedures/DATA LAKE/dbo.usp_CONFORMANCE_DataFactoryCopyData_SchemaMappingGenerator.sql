-- =============================================
-- Author:		Sherwin Zhao
-- Create date: 2022-09-20
-- Description:	This procedures generates the schema mapping information to be used in the Azure Data Factory Copy Data Activity to rename dataset columns
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[dbo.usp_CONFORMANCE_DataFactoryCopyData_SchemaMappingGenerator]
  @SourceDatabaseName VARCHAR(100),
  @SourceTableName VARCHAR(100),
  @SourceSchemaName VARCHAR(10)
AS
BEGIN
  BEGIN        
	SELECT
		STUFF(
			(
				SELECT
					'"}},{"source":{"name":"' + c.SourceColumnName + '","type":"' + c.TargetColumnType + '"}, "sink":{"name":"' + c.TargetColumnName + '","type": "' + c.TargetColumnType
				FROM
					dbo.metadata_control_conformance as c
				WHERE
						c.SourceDatabaseName = @SourceDatabaseName
					AND c.SourceTableSchemaName = @SourceSchemaName
					AND c.SourceTableName = @SourceTableName FOR XML PATH('')
			),
			1,
			4,
			'{"type": "TabularTranslator", "mappings": ['
		) +
		'"}}]}'
	AS SCHEMA_JSON_OUTPUT
  END
END