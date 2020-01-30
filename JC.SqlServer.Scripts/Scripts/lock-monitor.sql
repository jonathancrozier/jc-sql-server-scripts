-- Output any blocked/blocking processes.

SET NOCOUNT ON
GO

IF EXISTS (SELECT name
           FROM   tempdb..sysobjects
           WHERE  name = '#BlockedProcesses')
	DROP TABLE #BlockedProcesses
GO

CREATE TABLE #BlockedProcesses
(
    BlockedSPID   INT,
    BlockedStatus CHAR(10)
)
GO

INSERT INTO #BlockedProcesses
	SELECT DISTINCT spid, 'BLOCKED'
	FROM   master..sysprocesses
	WHERE  blocked <> 0
UNION
	SELECT DISTINCT blocked, 'BLOCKING'
	FROM   master..sysprocesses
	WHERE  blocked <> 0
 
DECLARE @LogBlockedSPID   INT 
DECLARE @LogBlockedStatus CHAR(10)

SELECT TOP 1 @LogBlockedSPID = BlockedSPID, @LogBlockedStatus = BlockedStatus
FROM #BlockedProcesses
 
WHILE(@@ROWCOUNT > 0)
    BEGIN
 
        PRINT 'DBCC Results for SPID ' + CAST(@LogBlockedSPID AS VARCHAR(5)) + ' (' + RTRIM(@LogBlockedStatus) + ')'
        PRINT '----------------------------------'
        PRINT ''
        DBCC INPUTBUFFER(@LogBlockedSPID)
        PRINT ''
 
        SELECT TOP 1 @LogBlockedSPID = BlockedSPID, @LogBlockedStatus = BlockedStatus
        FROM     #BlockedProcesses
        WHERE    BlockedSPID > @LogBlockedSPID
        ORDER BY BlockedSPID
 
    END
