-- Update the @ColumnName variable with the column search term.

DECLARE @ColumnName AS VARCHAR(MAX)
SET @ColumnName = '%COLUMN_TO_FIND%'

SELECT sys.schemas.name        AS [Schema],
       sys.tables.name		   AS [Table],
       sys.columns.name        AS [Column],
       sys.types.name          AS [Data Type],
       sys.columns.max_length  AS [Length],
       sys.columns.is_nullable AS [Is Nullable]
	        
FROM sys.schemas

INNER JOIN sys.tables  ON sys.schemas.schema_id    = sys.tables.schema_id
INNER JOIN sys.columns ON sys.tables.object_id     = sys.columns.object_id
INNER JOIN sys.types   ON sys.columns.user_type_id = sys.types.user_type_id

WHERE sys.columns.name LIKE @ColumnName

ORDER BY sys.tables.name, sys.columns.name