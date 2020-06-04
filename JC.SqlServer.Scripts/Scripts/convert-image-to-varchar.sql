-- Example of how to convert an IMAGE column to VARCHAR.
SELECT CONVERT(VARCHAR(MAX), 
               CONVERT(VARBINARY(MAX), 
                       (SELECT LargePhoto 
                        FROM dbo.DimProduct 
                        WHERE ProductKey = 101)))