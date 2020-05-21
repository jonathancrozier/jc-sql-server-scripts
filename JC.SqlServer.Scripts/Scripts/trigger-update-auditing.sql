-- ========================================================
-- TRIGGER
--     Stock Level Audit.
--
-- DESCRIPTION
--     Logs changes to the Stock Level of Products.
--
-- PREREQUISITES
--     Add a 'StockLevel' column to the 'dbo.DimProduct' 
--     table in the 'AdventureWorksDW{YYYY}' database.
--         ALTER TABLE dbo.DimProduct ADD StockLevel INT NOT NULL DEFAULT 0;
--
--     Add a 'DimProductStockLevelAudit' table to the
--     'AdventureWorks' database.
--         CREATE TABLE [dbo].[DimProductStockLevelAudit](	      
--         	   [ProductKey] [int] NOT NULL,
--         	   [ProductAlternateKey] [nvarchar](25) NULL,
--         	   [OldStockLevel] [int] NOT NULL,
--         	   [NewStockLevel] [int] NOT NULL,
--         	   [DateChanged] [datetime] NOT NULL
--         ) ON [PRIMARY]
-- 
-- ========================================================

CREATE TRIGGER StockLevelAudit
ON dbo.DimProduct
FOR UPDATE
NOT FOR REPLICATION
AS
BEGIN
    -- Only process if the Stock Level has been updated.
    IF UPDATE(StockLevel)
    BEGIN
        -- Inserting using the SELECT ensures that we capture all Stock Level changes.
	-- Triggers fire one time per command that makes a change to the table.
	INSERT INTO dbo.DimProductStockLevelAudit 
	    (ProductKey, 
	     ProductAlternateKey, 
	     OldStockLevel, 
             NewStockLevel, 
	     DateChanged) 
	SELECT 
	    i.ProductKey, 
	    i.ProductAlternateKey, 
	    d.StockLevel,
	    i.StockLevel,
	    GETDATE()
	FROM Inserted i -- 'Inserted' contains copies of the new values which have been updated in the virtual table.
	JOIN Deleted d ON i.ProductKey = d.ProductKey -- 'Deleted' contains copies of the old values which have been replaced.
	WHERE i.StockLevel <> d.StockLevel -- Only log changes if the Stock Level is different.
    END
END
