-- Example of how to find rows with duplicate values.
SELECT ProductAlternateKey, EnglishProductName, Color
FROM dbo.DimProduct 
WHERE EnglishProductName IN (SELECT EnglishProductName 
                             FROM dbo.DimProduct 
                             GROUP BY EnglishProductName 
                             HAVING COUNT(EnglishProductName) > 1) 
ORDER BY EnglishProductName