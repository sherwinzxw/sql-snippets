

-- =============================================
-- Author:		XINWEI ZHAO (SHERWIN)
-- Create date: 2022-08-25
-- Description:	This procedure searches the specified columns within the target database
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[dbo.usp_INFORMATIONSCHEMA_DatabaseTableColumns]
	@DatabaseName VARCHAR(255),
	@ColumnName VARCHAR(255)
AS

DECLARE 
	@SqlQuery VARCHAR(MAX) =  
	'SELECT 
		T.TABLE_CATALOG,
		T.TABLE_NAME,
		T.TABLE_SCHEMA,
		T.TABLE_TYPE,
		C.COLUMN_NAME,
		C.DATA_TYPE,
		C.IS_NULLABLE,
		C.CHARACTER_MAXIMUM_LENGTH	
	FROM ' +
		@DatabaseName + '.' + 'INFORMATION_SCHEMA.TABLES T ' +
	'INNER JOIN ' +
		@DatabaseName + '.' + 'INFORMATION_SCHEMA.COLUMNS C ' +
	'ON T.TABLE_NAME = C.TABLE_NAME WHERE T.TABLE_TYPE = ''BASE TABLE'' AND COLUMN_NAME LIKE ''%' + @ColumnName + '%''';

EXEC(@SqlQuery)
GO


