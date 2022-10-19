
CREATE OR ALTER PROCEDURE dbo.usp_DynamicSQL_DropExternalTables 
    @TargetSchema VARCHAR(255) 
AS 
    DECLARE @sql NVARCHAR(max) = '';
    SELECT
        @sql += ' DROP EXTERNAL TABLE ' + QUOTENAME(S.name) + '.' + QUOTENAME(E.name) + '; '
    FROM
        sys.external_tables E
        LEFT JOIN sys.schemas S ON E.schema_id = S.schema_id
    WHERE
        S.name = @TargetSchema;
    
    EXEC (@sql);
