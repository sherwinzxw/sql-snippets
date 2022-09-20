-- =============================================
-- Author:		Sherwin Zhao 
-- Create date: 2022-08-30
-- Description:	This procedure returns the loaded data row counts of the specified table from the last full load 
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[dbo.usp_FULL_UpdateMetadata]
	-- Add the parameters for the stored procedure here	
	@RowId INT,
	@SourceTableFullName VARCHAR(255)	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE 
		@SourceTableRowCounts INT
			
	DECLARE
		@DynamicSQL_SourceTableRowCounts NVARCHAR(MAX) = 
		'SELECT @SourceTableRowCounts = COUNT(*) FROM ' + @SourceTableFullName;
	EXEC sp_executesql @DynamicSQL_SourceTableRowCounts, N'@SourceTableRowCounts int out', @SourceTableRowCounts out
			
    -- Insert statements for procedure here
	BEGIN
		UPDATE dbo.metadata_control_landing
		SET 
			LastFullLoadRowCounts = @SourceTableRowCounts,
			LastDataLoadExecutionDateTime = SYSDATETIME()
		WHERE Id = @RowId
	END
END
