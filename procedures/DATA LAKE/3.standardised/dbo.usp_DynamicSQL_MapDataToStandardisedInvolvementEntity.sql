USE standardised;
GO

CREATE OR ALTER PROCEDURE sdt.usp_SELECT_Involvement
    @ConformanceTableSchemaName VARCHAR(255),
    @ConformanceTableName VARCHAR(255),
	@LeftEntityName VARCHAR(255),
    @LeftLegacyKeyPrefix VARCHAR(255),
    @LeftLegacyKeyValueColumn VARCHAR(255),
    @LeftLegacyKeySuffix VARCHAR(255) = NULL,
    @RightEntityName VARCHAR(255),
    @RightLegacyKeyPrefix VARCHAR(255),
    @RightLegacyKeyValueColumn VARCHAR(255),
    @RightLegacyKeySuffix VARCHAR(255) = NULL,
    @LeftRightType VARCHAR(255),
    @CheckCompletenessFlag BIT = 1
AS
	DECLARE @SQL_CHECK_COMPLETENESS_TRUE NVARCHAR(MAX) =    
    'WITH CTE_INVOLVEMENT AS (        
        SELECT '
	+
		'''' + @LeftLegacyKeyPrefix + '-''+' + 'CONVERT(VARCHAR(255), ' + @LeftLegacyKeyValueColumn + ') + ''' + ISNULL('-' + @LeftLegacyKeySuffix, '') + ''' AS LeftLK,' +
        '''' + @RightLegacyKeyPrefix + '-''+' + 'CONVERT(VARCHAR(255), ' + @RightLegacyKeyValueColumn + ') + ''' + ISNULL('-' + @RightLegacyKeySuffix, '') + ''' AS RightLK,' +
    '''' + @LeftRightType + '''' + ' AS LeftRightType,' +
    '''' + @LeftEntityName + '''' + ' AS LeftEntityName,' +
    '''' + @RightEntityName + '''' + ' AS RightEntityName
	' +
    ' FROM conformance.' +  @ConformanceTableSchemaName + '.' + @ConformanceTableName + 
    ' WHERE ' + @LeftLegacyKeyValueColumn + ' IS NOT NULL AND ' + ISNULL(@RightLegacyKeySuffix, @RightLegacyKeyValueColumn) +  ' IS NOT NULL' +
    ') SELECT * FROM CTE_INVOLVEMENT WHERE LeftLK IS NOT NULL AND RightLK IS NOT NULL;'
    
    DECLARE @SQL_CHECK_COMPLETENESS_FALSE NVARCHAR(MAX) = 
        'WITH CTE_INVOLVEMENT AS (        
        SELECT '
	+
		'''' + @LeftLegacyKeyPrefix + '-''+' + 'CONVERT(VARCHAR(255), ' + @LeftLegacyKeyValueColumn + ') + ''' + ISNULL('-' + @LeftLegacyKeySuffix, '') + ''' AS LeftLK,' +
        '''' + @RightLegacyKeyPrefix + '-''+' + 'CONVERT(VARCHAR(255), ' + @RightLegacyKeyValueColumn + ') + ''' + ISNULL('-' + @RightLegacyKeySuffix, '') + ''' AS RightLK,' +
    '''' + @LeftRightType + '''' + ' AS LeftRightType,' +
    '''' + @LeftEntityName + '''' + ' AS LeftEntityName,' +
    '''' + @RightEntityName + '''' + ' AS RightEntityName
	' +
    ' FROM conformance.' +  @ConformanceTableSchemaName + '.' + @ConformanceTableName + 
    ') SELECT * FROM CTE_INVOLVEMENT WHERE LeftLK IS NOT NULL AND RightLK IS NOT NULL;'

    IF @CheckCompletenessFlag = 1
        BEGIN 
            EXEC (@SQL_CHECK_COMPLETENESS_TRUE)
        END 
    ELSE 
        BEGIN
            EXEC (@SQL_CHECK_COMPLETENESS_FALSE)
        END 