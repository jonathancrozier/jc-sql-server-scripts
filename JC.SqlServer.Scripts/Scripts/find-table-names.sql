-- Update the @TableName variable with the column search term.

DECLARE @TableName AS VARCHAR(MAX)
SET @TableName = '%TABLE_TO_FIND%'

SELECT sys.schemas.[name] AS [Schema],
       sys.tables.[name] AS [Table],
	   sys.tables.create_date AS [Created Date],
	   sys.tables.modify_date AS [Modified Date],
	   sys.tables.max_column_id_used AS [Max Column ID Used]

FROM sys.schemas

INNER JOIN sys.tables ON sys.schemas.schema_id = sys.tables.schema_id

WHERE sys.tables.[name] LIKE @TableName

ORDER BY sys.tables.[name]