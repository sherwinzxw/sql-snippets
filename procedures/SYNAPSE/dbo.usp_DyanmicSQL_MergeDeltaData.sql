CREATE PROCEDURE dbo.usp_DynamicSQL_MergeDeltaData 
    @SchemaName VARCHAR(255),
    @TableName VARCHAR(255),
    @PrimaryKeyColumnName VARCHAR(255),
    @WatermarkColumnName VARCHAR(255) 
AS 
    DECLARE @SQL VARCHAR(MAX) = CONCAT(
        'SELECT TOP 1 WITH TIES * FROM ',
        @SchemaName,
        '.',
        @TableName,
        ' ORDER BY ROW_NUMBER() OVER (PARTITION BY ',
        @PrimaryKeyColumnName,
        ' ORDER BY ',
        @WatermarkColumnName,
        ' DESC)'
    );

    EXEC (@SQL);