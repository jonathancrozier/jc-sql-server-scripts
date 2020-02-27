-- Parse the individual name parts from the full name of each customer record.
-- Update customer records for which a Title, First Name and Last Name have not already been set.
 
SET NOCOUNT ON
GO
 
-- Customer table column values.
DECLARE @CustomerId	         INT;
DECLARE @CustomerAccountName NVARCHAR(108);
DECLARE @CustomerTitle       NVARCHAR(8);
DECLARE @CustomerFirstName   NVARCHAR(50);
DECLARE @CustomerLastName    NVARCHAR(50);
 
-- Initialise cursor.
DECLARE CustomersCursor CURSOR 
    LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 
SELECT DISTINCT CustomerKey, AccountName, Title, FirstName, LastName FROM DimCustomer
 
OPEN CustomersCursor
FETCH NEXT FROM CustomersCursor 
    INTO @CustomerId, @CustomerAccountName, @CustomerTitle, @CustomerFirstName, @CustomerLastName
WHILE @@FETCH_STATUS = 0
BEGIN 
    -- Temporary variables.
    DECLARE @Title     NVARCHAR(8);
    DECLARE @FirstName NVARCHAR(50);
    DECLARE @LastName  NVARCHAR(50);
 
    -- Index and word variables.
    DECLARE @AccountNameEndIndex INT;
    DECLARE @FirstWordEndIndex   INT;
    DECLARE @SecondWordEndIndex  INT;
    DECLARE @ThirdWordEndIndex   INT;
    DECLARE @FirstWord			 NVARCHAR(8);
    DECLARE @SecondWord		     NVARCHAR(50);
    DECLARE @ThirdWord		     NVARCHAR(50);
 
    -- Get the last index.
    SET @AccountNameEndIndex = LEN(@CustomerAccountName) - 1;
    
    -- Get the first word.
    SET @FirstWordEndIndex = (SELECT CHARINDEX(' ', @CustomerAccountName, 0));
    SET @FirstWord		   = SUBSTRING(@CustomerAccountName, 0, @FirstWordEndIndex);
    
    -- Get the second word.
    SET @SecondWordEndIndex = (SELECT CHARINDEX(' ', @CustomerAccountName, @FirstWordEndIndex + 1));
    
    IF @SecondWordEndIndex = 0
    	BEGIN
    		SELECT @SecondWordEndIndex = @AccountNameEndIndex;
    
    		SET @SecondWord	= SUBSTRING(@CustomerAccountName, @FirstWordEndIndex + 1, @SecondWordEndIndex - (@FirstWordEndIndex - 1));
    	END
    ELSE
    	BEGIN
    		SET @SecondWord	= SUBSTRING(@CustomerAccountName, @FirstWordEndIndex + 1, @SecondWordEndIndex - (@FirstWordEndIndex + 1));
    	END
    
    -- Get the third word.
    SET @ThirdWordEndIndex = @AccountNameEndIndex;
    
    IF @ThirdWordEndIndex <> @SecondWordEndIndex
    	BEGIN
    		SET @ThirdWord = SUBSTRING(@CustomerAccountName, @SecondWordEndIndex + 1, @ThirdWordEndIndex - (@SecondWordEndIndex - 1));
    	END
    
    -- Check if the first word is a 'Title'.
    SELECT @Title = CASE LTRIM(RTRIM(@FirstWord)) WHEN 'Dr'	   THEN 'Dr'
    											  WHEN 'Dr.'   THEN 'Dr.'
    											  WHEN 'Miss'  THEN 'Miss'
    											  WHEN 'Miss.' THEN 'Miss.'
    											  WHEN 'Mr'	   THEN 'Mr'
    											  WHEN 'Mr.'   THEN 'Mr.'
    											  WHEN 'Mrs'   THEN 'Mrs'
    											  WHEN 'Mrs.'  THEN 'Mrs.'
    											  WHEN 'Ms'	   THEN 'Ms'
    											  WHEN 'Ms.'   THEN 'Ms.'
    											  WHEN 'Rev'   THEN 'Rev'
    											  WHEN 'Rev.'  THEN 'Rev.'
    											  ELSE '' 
    											  END
    
    IF @Title = ''
    	BEGIN
    		IF LTRIM(RTRIM(@FirstWord)) = ''
    			BEGIN
    				-- There is only one word, use this as the First Name.
    				SELECT @FirstName = LTRIM(RTRIM(@SecondWord));
    				SELECT @LastName  = '';
    			END
    		ELSE
    			BEGIN
    				-- There are two words, set First Name and Last Name.
    				SELECT @FirstName = LTRIM(RTRIM(@FirstWord));
    				SELECT @LastName  = LTRIM(RTRIM(@SecondWord));
    			END
    	END
    ELSE 
    	BEGIN
    		-- There are three words, set First Name and Last Name.
    		-- Title has already been set.
    		SELECT @FirstName = LTRIM(RTRIM(@SecondWord));
    		SELECT @LastName  = LTRIM(RTRIM(@ThirdWord));
    	END
    
    -- Output the combination of the name parts for reference.
    PRINT @Title + ' ' + @FirstName + ' ' + @LastName;	
    
    -- Update the current Customer values.
    IF (LEN(ISNULL(@CustomerTitle    , '')) = 0) AND 
       (LEN(ISNULL(@CustomerFirstName, '')) = 0) AND 
       (LEN(ISNULL(@CustomerLastName , '')) = 0)
       BEGIN
    	   UPDATE DimCustomer 
    	   SET    Title = @Title, FirstName = @FirstName, LastName = @LastName 
    	   WHERE  CustomerKey = @CustomerId;
       END
    
    FETCH NEXT FROM CustomersCursor INTO @CustomerId, @CustomerAccountName, @CustomerTitle, @CustomerFirstName, @CustomerLastName
END
CLOSE CustomersCursor
DEALLOCATE CustomersCursor