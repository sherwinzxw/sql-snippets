
-- =============================================
-- Author:		Sherwin Zhao 
-- Create date: 2022-08-30
-- Description:	This procedure update watermark value for delta load based on Datetime type column
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_ADF_Update_WatermarkValue_DateTime]
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
		@NewWatermarkValue DATETIME,
		@DynamicSQL NVARCHAR(MAX);
	
	SET @DynamicSQL = 'SELECT @NewWatermarkValue = MAX(' + @WatermarkColumnName + ') FROM ' + @SourceTableName;
	
	EXEC sp_executesql @DynamicSQL, N'@NewWatermarkValue DATETIME out', @NewWatermarkValue out

    -- Insert statements for procedure here
	BEGIN
		UPDATE dbo.metadata_control_landing
		SET 
			DeltaLoadLastDateTimeWaterMarkValue = @NewWatermarkValue,
			LastDataLoadExecutionDateTime = SYSDATETIME()
		WHERE Id = @RowId
	END
END
