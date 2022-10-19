use landing;
GO
CREATE OR ALTER PROCEDURE dbo.usp_DynamicSQL_GenerateScript_CET 
    @SourceDatabase VARCHAR(255),
	@SourceTableName VARCHAR(255),
	@Schema VARCHAR(255),
	@BlobLocation VARCHAR(255),
	@DataSource VARCHAR(255),
	@FileFormat VARCHAR(255)
AS 
WITH CTE AS (
    SELECT
        CASE
            WHEN C.DATA_TYPE LIKE '%char%'
            AND CHARACTER_MAXIMUM_LENGTH > 0 THEN 'nvarchar(4000)'
            WHEN C.DATA_TYPE LIKE '%char%'
            AND CHARACTER_MAXIMUM_LENGTH < 0 THEN 'nvarchar(MAX)'
            WHEN C.DATA_TYPE LIKE '%text%' THEN 'nvarchar(MAX)'
            WHEN C.DATA_TYPE LIKE '%Date%' THEN 'datetime2(7)'
            ELSE C.DATA_TYPE
        END AS Data_Type_New,
        *
    FROM
        [dbo].[SOURCE_DATABASE_INFORMATION_SCHEMA] C
    WHERE
        TABLE_CATALOG = @SourceDatabase
	AND TABLE_NAME = @SourceTableName
),
CTE_DDL AS (
    SELECT
        TABLE_NAME,
        COLUMN_NAME + ' ' + Data_Type_New AS ColumnDefinition
    FROM
        CTE
)
,CTE_PRE_CREATE_DDL AS (
    SELECT
        TABLE_NAME,
        STRING_AGG(CONVERT(NVARCHAR(max), ColumnDefinition), ',') AS CTE_DDL
    FROM
        CTE_DDL
    GROUP BY
        TABLE_NAME
)
SELECT
    CONCAT(
        'IF OBJECT_ID(N''', ISNULL(@Schema, ''), '.', ISNULL(TABLE_NAME, ''), ''') IS NOT NULL ',
        'BEGIN DROP EXTERNAL TABLE ', ISNULL(@Schema, ''),'.',ISNULL(TABLE_NAME, ''),' END; ',        
        'CREATE EXTERNAL TABLE ',
        ISNULL(@Schema, ''),
        '.',
        ISNULL(TABLE_NAME, ''),
        ' (',
        CTE_DDL,
        ')',
        ' WITH (',
        'LOCATION=', 
		'''',       
        ISNULL(@BlobLocation, ''),
        '''',
        ',DATA_SOURCE=',
        ISNULL(@DataSource, ''),
        ',FILE_FORMAT=',
        ISNULL(@FileFormat, ''),
        ')'
    ) AS CET
FROM
    CTE_PRE_CREATE_DDL
