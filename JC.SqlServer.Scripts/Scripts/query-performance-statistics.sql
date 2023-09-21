-- Example of how to extract performance statistics for currently running queries in a SQL Server instance.
SELECT
    r.session_id AS [Session ID],
    s.database_id AS [Database ID],
    DB_NAME(s.database_id) AS [Database Name],
    r.total_elapsed_time AS [Elapsed Time (ms)],
    r.cpu_time AS [CPU Time (ms)],
    r.writes AS [Writes],
    r.reads AS [Reads],
    r.logical_reads AS [Logical Reads],
    r.[status] AS [Status],
    t.[text] AS [SQL Text]
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) AS t
INNER JOIN sys.dm_exec_sessions AS s ON r.session_id = s.session_id
WHERE r.session_id > 50  -- Exclude system sessions.
ORDER BY r.total_elapsed_time DESC, r.cpu_time DESC