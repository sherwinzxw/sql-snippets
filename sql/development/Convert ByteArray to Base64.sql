WITH CTE AS (
	SELECT 
		ByteArrayColumn 
	FROM dbo.tblPhoto
	WHERE PhotoID = 3
)

SELECT CONVERT(varbinary(MAX), ByteArrayColumn)  FROM CTE FOR XML PATH('')