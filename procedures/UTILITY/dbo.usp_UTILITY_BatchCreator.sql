-- =============================================
-- Author:		SHERWIN ZHAO
-- Create date: 2022-09-20
-- Description:	This procedure creates the data batches based on the specified source data size and batch size
-- 				The batches are created to be used for parallel batch processing.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_UTILITY_BatchCreator]
	-- Add the parameters for the stored procedure here
	@SourceDataSizeTotal INT,
	@BatchSize INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @BatchNumber INT = ROUND( @SourceDataSizeTotal / @BatchSize, 0) + 1;

    -- Insert statements for procedure here
	WITH 
		E00(N) AS (SELECT 1 UNION ALL SELECT 1)
		,E02(N) AS (SELECT 1 FROM E00 a, E00 b)
		,E04(N) AS (SELECT 1 FROM E02 a, E02 b)
		,E08(N) AS (SELECT 1 FROM E04 a, E04 b)
		,E16(N) AS (SELECT 1 FROM E08 a, E08 b)
		,E32(N) AS (SELECT 1 FROM E16 a, E16 b)
		,cteTally(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E32),

	CTE_Batches AS (
		SELECT 
			ROW_NUMBER() OVER (ORDER BY N) AS BatchNumber,
			N * @BatchSize - (@BatchSize - 1) AS BatchStart,
			N * @BatchSize AS BatchEnd
		FROM cteTally
		WHERE N <= @BatchNumber
	)

	SELECT * FROM CTE_Batches
END
