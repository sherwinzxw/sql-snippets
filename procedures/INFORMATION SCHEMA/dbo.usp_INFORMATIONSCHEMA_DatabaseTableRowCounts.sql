-- =============================================
-- Author:		XINWEI ZHAO (SHERWIN)
-- Create date: 2022-08-25
-- Description:	This procedure returns the table row counts for the specified schema (optional) and table name (optionl)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_INFORMATIONSCHEMA_DatabaseTableRowCounts] 
	@SchemaNameOptional VARCHAR(255) = NULL,
	@TableNameOptional VARCHAR(255) = NULL
AS 
	WITH CTE AS (
		SELECT
			QUOTENAME(SCHEMA_NAME(SYSOBJ.schema_id)) + '.' + QUOTENAME(SYSOBJ.name) AS [QuoteTableName],
			SCHEMA_NAME(SYSOBJ.schema_id) AS SchemaName,
			SYSOBJ.name AS TableName,
			SUM(SYSPARTITION.Rows) AS [RowCount]
		FROM 
			sys.objects AS SYSOBJ
			INNER JOIN sys.partitions AS SYSPARTITION ON SYSOBJ.object_id = SYSPARTITION.object_id
		WHERE
			SYSOBJ.type = 'U'
		AND SYSOBJ.is_ms_shipped = 0x0
		AND index_id < 2 -- 0:Heap, 1:Clustered
		GROUP BY
			  SYSOBJ.schema_id,
			  SYSOBJ.name
	)

	SELECT 
		* 
	INTO #temp_TableRowCounts
	FROM CTE 

	IF @SchemaNameOptional IS NULL AND @TableNameOptional IS NULL
	BEGIN 
		SELECT * FROM #temp_TableRowCounts
		ORDER BY [QuoteTableName]
	END 
	
	IF @SchemaNameOptional IS NULL AND @TableNameOptional IS NOT NULL
	BEGIN 
		SELECT * FROM #temp_TableRowCounts
		WHERE TableName = @TableNameOptional
		ORDER BY [QuoteTableName]
	END 
	
	IF @SchemaNameOptional IS NOT NULL AND @TableNameOptional IS NULL
	BEGIN 
		SELECT * FROM #temp_TableRowCounts
		WHERE SchemaName = @SchemaNameOptional
		ORDER BY [QuoteTableName]
	END 
	
	IF @SchemaNameOptional IS NOT NULL AND @TableNameOptional IS NOT NULL
	BEGIN 
		SELECT * FROM #temp_TableRowCounts
		WHERE SchemaName = @SchemaNameOptional AND TableName = @TableNameOptional
		ORDER BY [QuoteTableName]
	END 

	DROP TABLE #temp_TableRowCounts;	
GO
