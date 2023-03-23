-- Example of how to list the number of records for each table in a SQL Server database.
SELECT 
    SCHEMA_NAME(t.[schema_id]) + '.' + t.[name] AS [Table Name],
    p.[rows] AS [Row Count],
    (SUM(a.total_pages) * 8) / 1024 AS [Total Space (MB)],
    (SUM(a.used_pages) * 8) / 1024 AS [Used Space (MB)],
    (SUM(a.data_pages) * 8) / 1024 AS [Data Space (MB)]
FROM sys.tables t
INNER JOIN sys.indexes i ON t.[object_id] = i.[object_id]
INNER JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
WHERE -- Exclude system tables and indexes.
    t.is_ms_shipped = 0 AND
    t.[name] NOT LIKE 'dt%' AND
    i.[object_id] > 255 AND   
    i.index_id <= 1
GROUP BY 
    t.[schema_id], 
    t.[name], 
    p.[rows], 
    i.[object_id]
ORDER BY p.[rows] DESC