SELECT
    SCHEMA_NAME(T.schema_id) AS [SCHEMA_NAME],
    PK.[name] AS PK_NAME,
    SUBSTRING(COLUMN_NAMES, 1, LEN(COLUMN_NAMES) -1) AS [COLUMNS],
    T.[name] AS TABLE_NAME
FROM
    sys.tables T
    INNER JOIN sys.indexes PK ON T.object_id = PK.object_id
    AND PK.is_primary_key = 1
    CROSS APPLY (
        SELECT
            C.[name] + ', '
        FROM
            sys.index_columns IC
            INNER JOIN sys.columns C ON IC.object_id = C.object_id
            AND IC.column_id = C.column_id
        WHERE
            IC.object_id = T.object_id
            AND IC.index_id = PK.index_id           
        ORDER BY
            C.column_id for XML PATH ('')
    ) D (COLUMN_NAMES)
ORDER BY
    SCHEMA_NAME(T.schema_id),
    PK.[name]