WITH CTE_PHONE AS (
 SELECT 
 CA.*,
 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CA.CommAddressValue,'-',''),'.',''),' 
',''),')',''),'(',''),'#',''),'/',''),'\','') AS CommAddressValue1stETL
 FROM tblCommAddress CA
 WHERE CommAddressType = 'Phone'
)
,CTE_PHONE_2ETL AS (
 SELECT
 NULLIF(
 LEFT(SUBSTRING(CommAddressValue1stETL, PATINDEX('%[0-9]%', CommAddressValue1stETL), 8000),
 PATINDEX('%[^0-9]%', SUBSTRING(CommAddressValue1stETL, PATINDEX('%[0-9]%', CommAddressValue1stETL), 
8000) + 'X') -1),''
 ) AS CommAddressValue2ndETL,
 * 
 FROM CTE_PHONE
)
,CTE_PHONE_3ETL AS (
 SELECT 
 CASE 
 WHEN LEN(CommAddressValue2ndETL) = 10 AND LEFT(CommAddressValue2ndETL, 2) IN ('02', '03', 
'04','07','08') THEN 0
 WHEN LEN(CommAddressValue2ndETL) = 10 AND LEFT(CommAddressValue2ndETL, 4) IN ('1800', '1300') THEN 0
 WHEN LEN(CommAddressValue2ndETL) = 6 AND LEFT(CommAddressValue2ndETL, 2) IN ('13') THEN 0
 ELSE 1
 END AS RequireReivewFlag,
 CASE
 WHEN LEN(CommAddressValue2ndETL) = 10 AND LEFT(CommAddressValue2ndETL, 2) IN ('02', '03', 
'07','08') THEN 'RE'
 WHEN LEN(CommAddressValue2ndETL) = 10 AND LEFT(CommAddressValue2ndETL, 2) IN ('04') THEN 'MOBIL'
 WHEN LEN(CommAddressValue2ndETL) = 10 AND LEFT(CommAddressValue2ndETL, 4) IN ('1800', '1300') THEN 
'BUS'
 WHEN LEN(CommAddressValue2ndETL) = 6 AND LEFT(CommAddressValue2ndETL, 2) IN ('13') THEN 'BUS'
 ELSE NULL
 END AS PhoneType,
 * 
 FROM CTE_PHONE_2ETL
 WHERE CommAddressValue2ndETL IS NOT NULL
)

SELECT * FROM CTE_PHONE_3ETL
