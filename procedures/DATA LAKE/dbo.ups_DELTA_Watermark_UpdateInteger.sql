

-- =============================================
-- Author:		Sherwin Zhao 
-- Create date: 2022-08-30
-- Description:	This procedure update watermark value for delta load based on Integer type column
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[dbo.ups_DELTA_Watermark_UpdateInteger]
	-- Add the parameters for the stored procedure here	
	@RowId INT,
	@SourceTableName VARCHAR(255),
	@WatermarkColumnName VARCHAR(255)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE 
		@NewWatermarkValue INT = 0,
		@DynamicSQL nvarchar(MAX);

	
	SET @DynamicSQL = 
		'SELECT @NewWatermarkValue = MAX(' + @WatermarkColumnName + ') FROM ' + @SourceTableName;
	
	EXEC sp_executesql @DynamicSQL, N'@NewWatermarkValue int out', @NewWatermarkValue out
		
    -- Insert statements for procedure here
	BEGIN
		UPDATE dbo.metadata_control_landing
		SET 
			DeltaLoadLastIntegerWaterMarkValue = @NewWatermarkValue,
			LastDataLoadExecutionDateTime = SYSDATETIME()
		WHERE Id = @RowId
	END
END
