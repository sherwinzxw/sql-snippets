SELECT 
    o.name AS ObjectName,
    o.type_desc AS ObjectType,
    m.definition AS ObjectDefinition
FROM sys.sql_modules m 
INNER JOIN sys.objects o ON m.object_id = o.object_id
ORDER BY o.type_desc, o.name