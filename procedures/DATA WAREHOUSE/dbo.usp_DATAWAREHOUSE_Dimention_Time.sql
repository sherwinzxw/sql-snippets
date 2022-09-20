
-- =============================================
-- Author:		Sherwin Zhao
-- Create date: 2022-08-26
-- Description:	This procedure create and populate a Data Warehouse Time dimension table
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_DATAWAREHOUSE_Dimension_Time]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
/********************************************************************************************
	
	Author:			Xinwei (Sherwin) Zhao | sherwin.zhao@justice.tas.gov.au
	Date:			2022-07-21
	Description:	This script geneates the list of dates that builds the global dimension 
					date table.					


	Change Log:
	Change#			ChangeDate			ChangeAuthor			ChangeNote
	[101]			2022-08-30			Sherwin Zhao			Discard the Recursive CTE approach and instead uses CTE Tally
*********************************************************************************************/
			
						
--============================================================================================
--	DECLARE ENVIRONMENT VARIABLES
--============================================================================================
DECLARE 
	@FromDate    DATE = '1900-01-01',
    @ToDate      DATE = CONVERT(VARCHAR(10), DATEPART(YEAR, DATEADD(YEAR, 75, GETDATE()))) + '-12' + '-31';

DECLARE 
	@FromToDateDiff INT = DATEDIFF(Day, @FromDate, @ToDate) 

--============================================================================================
-- CODE STARTS BELOW
--============================================================================================

-- STEP 0: truncate destination table
TRUNCATE TABLE dbo.tblDimTime	


;WITH E00(N) AS (SELECT 1 UNION ALL SELECT 1)
    ,E02(N) AS (SELECT 1 FROM E00 a, E00 b)
    ,E04(N) AS (SELECT 1 FROM E02 a, E02 b)
    ,E08(N) AS (SELECT 1 FROM E04 a, E04 b)
    ,E16(N) AS (SELECT 1 FROM E08 a, E08 b)
    ,E32(N) AS (SELECT 1 FROM E16 a, E16 b)
    ,cteTally(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E32),


---- STEP 1: return all dates within defined range
CTE_DATE AS (
	SELECT DATEADD(DAY, N - 1, @FromDate) AS InputDate
	FROM cteTally
	WHERE N <= @FromToDateDiff
)

---- [101] start
	--;WITH CTE_DATE (InputDate) AS		
	--(
	--    SELECT
	--		 @FromDate 
	--	UNION ALL
    
	--	SELECT DATEADD(DAY, 1, InputDate)
	--    From    CTE_DATE
	--    WHERE   InputDate < @ToDate
	--),
---- [101] end

-- STEP 2: build date elements for each iterated date
,CTE_BUILD AS						
(
	SELECT  
			CONVERT(DATE, InputDate)				AS [Date],
			CONVERT(NVARCHAR(10), InputDate, 23)	AS [DateStringISO1806],
			CONVERT(NVARCHAR(10), InputDate, 23)	AS [CensusDate],
			CONVERT(NVARCHAR(10), InputDate, 103)	AS [FullDateAUS],
			CONVERT(NVARCHAR(10), InputDate, 101)	AS [FullDateUSA],
			DATEPART(YEAR, InputDate)				AS [Year],
			DATEPART(QUARTER, InputDate)			AS [Quater],
			DATEPART(MONTH, InputDate)				AS [Month],
			DATENAME(MONTH, InputDate)				AS [MonthName],
			DATEPART(DAY, InputDate)				AS [DayOfMonth],			
			DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, InputDate), 0), InputDate) + 1 AS DayOfQuarter,
			DATEPART(DAYOFYEAR, InputDate)			AS [DayOfYear],
			DATEPART(WEEK, InputDate)				AS [WeekOfYear],
			DATEPART(WEEKDAY, InputDate)			AS [Weekday],
			DATENAME(WEEKDAY, InputDate)			AS [DayName]
	FROM  CTE_DATE
),

-- STEP 3: generate surrogate id and checksum
CTE_CHECKSUM AS	
(
	SELECT
		CAST(REPLACE(CONVERT(VARCHAR(10), [Date]), '-','') AS INT) AS DateKey,	-- row_number value is to be used for globally unique surrogate key
		*,
		CASE 
			WHEN [DayOfMonth] IN (1, 21) THEN  CONVERT(VARCHAR(2), [DayOfMonth]) + 'st'
			WHEN [DayOfMonth] IN (2, 22) THEN  CONVERT(VARCHAR(2), [DayOfMonth]) + 'nd'
			WHEN [DayOfMonth] IN (3, 23) THEN  CONVERT(VARCHAR(2), [DayOfMonth]) + 'rd'
			ELSE CONVERT(VARCHAR(2), [DayOfMonth]) + 'th'
		END AS DaySuffix,
		CASE 
			WHEN Weekday >= 6 THEN 0
			ELSE 1
		END AS IsWeekday,
		LEFT([MonthName], 3) + ' ' + CAST([DayOfMonth] AS VARCHAR(2)) AS DayMonth,
		LEFT([MonthName], 3) + ' ' + CAST([Year] AS VARCHAR(4)) AS MonthYear,
		CASE 
			WHEN [Month] >= 7 THEN CAST([Year] AS VARCHAR(4)) + '/' + CAST(([Year] + 1) AS VARCHAR(4))
			ELSE  CAST(([Year] - 1) AS VARCHAR(4)) + '/' +  CAST([Year] AS VARCHAR(4)) 
		END AS FiscalYear,
		CASE 
			WHEN [Month] >= 7 THEN LEFT(MonthName, 3) + ' ' + CAST([Year] AS VARCHAR(4)) + '/' + CAST(([Year] + 1) AS VARCHAR(255))
			ELSE LEFT(MonthName, 3) + ' ' + CAST(([Year] - 1) AS VARCHAR(255)) + '/' +  CAST([Year] AS VARCHAR(255)) 
		END AS FiscalMonthYear,
		'Q' + CAST([Quater] AS VARCHAR(1)) + ' ' + CAST([Year] AS VARCHAR(4)) AS QuarterYear,
		CASE 
			WHEN DayOfMonth = 1 AND Month = 1 THEN 1
			WHEN DayOfMonth = 26 AND Month = 1 THEN 1
			WHEN DayOfMonth = 25 AND Month = 4 THEN 1
			WHEN DayOfMonth = 25 AND Month = 12 THEN 1
			WHEN DayOfMonth = 26 AND Month = 12 THEN 1
			ELSE 0
		END AS IsAustraliaPublicHoliday,
		CASE 
			WHEN DayOfMonth = 1 AND Month = 1 THEN 'New year day'
			WHEN DayOfMonth = 26 AND Month = 1 THEN 'Australia day'
			WHEN DayOfMonth = 25 AND Month = 4 THEN 'ANZAC'
			WHEN DayOfMonth = 25 AND Month = 12 THEN 'Chrismas'
			WHEN DayOfMonth = 26 AND Month = 12 THEN 'Boxing Day'
			ELSE NULL
		END AS AustraliaPublicHolidayName,
		CHECKSUM(*) AS [checksum]					-- checksum value is to be used for uniqueness check after the table build
	FROM CTE_BUILD
)

-- STEP 4: generate dimension date dataset for import table build
INSERT INTO dbo.tblDimTime (
	[DateKey],
	[Date],
	[DateStringISO1806],
	[CensusDate],
	[FullDateAUS],
	[FullDateUSA],
	[DayOfMonth],
	[DaySuffix],
	[DayName],
	[Weekday],
	[DayOfQuarter],
	[DayOfYear],
	[Year],
	[Quater],
	[Month],
	[MonthName],
	[WeekOfYear],
	[IsWeekday],
	[DayMonth],
	[MonthYear],
	[FiscalYear],
	[FiscalMonthYear],
	[QuarterYear],
	[IsAustraliaPublicHoliday],
	[AustraliaPublicHolidayName],
	[checksum]
)

SELECT 
	[DateKey],
	[Date],
	[DateStringISO1806],
	[CensusDate],
	[FullDateAUS],
	[FullDateUSA],
	[DayOfMonth],
	[DaySuffix],
	[DayName],
	[Weekday],
	[DayOfQuarter],
	[DayOfYear],
	[Year],
	[Quater],
	[Month],
	[MonthName],
	[WeekOfYear],
	[IsWeekday],
	[DayMonth],
	[MonthYear],
	[FiscalYear],
	[FiscalMonthYear],
	[QuarterYear],
	[IsAustraliaPublicHoliday],
	[AustraliaPublicHolidayName],
	[checksum]
FROM 
	CTE_CHECKSUM
ORDER BY DateKey DESC
--	OPTION  (MaxRecursion 0) - [101]
END
