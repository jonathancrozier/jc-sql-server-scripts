-- Example of how to construct an UPDATE statement which requires a JOIN.
UPDATE dbo.DimProductSubcategory 
SET EnglishProductSubcategoryName = 
    dbo.DimProductCategory.EnglishProductCategoryName + ': ' + 
    DimProductSubcategory.EnglishProductSubcategoryName 
FROM dbo.DimProductSubcategory 
INNER JOIN dbo.DimProductCategory ON 
           DimProductSubcategory.ProductCategoryKey = 
           dbo.DimProductCategory.ProductCategoryKey
WHERE dbo.DimProductCategory.EnglishProductCategoryName IS NOT NULL