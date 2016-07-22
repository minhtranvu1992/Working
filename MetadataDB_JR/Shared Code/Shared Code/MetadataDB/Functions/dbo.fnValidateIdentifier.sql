

CREATE FUNCTION [dbo].[fnValidateIdentifier](@Identifier VARCHAR(254), @IncludeInBuild BIT)
RETURNS @retInfo TABLE 
(
    -- Columns returned by the function
     ViolatedRule INT,
     Severity VARCHAR(40),
	ViolatedDescription VARCHAR(200),
	Mitigation VARCHAR(250)

	/*
	Creator			: Ba Nguyen
	Created Date	: Jul 21, 2014

	Rule 0: NULL or EMPTY not allowed
	Rule 1: Lengh of string less than 128
	Rule 2: First character must be a letter
	Rule 3: Embedded spaces not allowed
	Rule 4: Do not use reserved words

	This function will check an identifier valid or invalid. 
	Return : 0 is valid
	Return : <> 0 is invalid
	*/
)

AS 
-- Returns the first name, last name, job title, and contact type for the specified contact.
BEGIN
    DECLARE 

			@Rule0 INT = 1,
			@Severity0 VARCHAR(40), 
			@Rule0Desc VARCHAR(200) = 'NULL or EMPTY not allowed: [' + @Identifier + ']',
			@Rule0Mitigation VARCHAR(250) = 'replace NULL or EMPTY values by another one',

			@Rule1 INT = 2,
			@Severity1 VARCHAR(40), 
			@Rule1Desc VARCHAR(200) = 'Lengh of string less than 128: [' + @Identifier + ']',
			@Rule1Mitigation VARCHAR(250) = 'make your string less than 128 characters',

			@Rule2 INT = 3,
			@Severity2 VARCHAR(40), 
			@Rule2Desc VARCHAR(200) = 'First character must be a letter: [' + @Identifier + ']',
			@Rule2Mitigation VARCHAR(250) ='replace the first character by a letter',

			@Rule3 INT = 4,
			@Severity3 VARCHAR(40), 
			@Rule3Desc VARCHAR(200) = 'Embedded spaces not allowed: [' + @Identifier + ']',
			@Rule3Mitigation VARCHAR(250) = 'remove all spaces from your string',

			@Rule4 INT = 5,
			@Severity4 VARCHAR(40), 
			@Rule4Desc VARCHAR(200) = 'Do not use reserved words: [' + @Identifier + ']',
			@Rule4Mitigation VARCHAR(250) = 'replace reserved words by none-reserved words'
	
	--Rule 0: NULL or EMPTY not allowed
	IF(@Identifier IS NULL OR @Identifier = '')
	BEGIN
	     SET @Severity0 = (CASE WHEN @IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END)
		INSERT INTO @retInfo(ViolatedRule,Severity,ViolatedDescription,Mitigation) VALUES (@Rule0,@Severity0,@Rule0Desc,@Rule0Mitigation)
	END

	--Rule 1: Lengh less than 128
	IF LEN(@Identifier) >128 
	BEGIN 
	     SET @Severity1 = (CASE WHEN @IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END)
		INSERT INTO @retInfo(ViolatedRule,Severity,ViolatedDescription,Mitigation) VALUES (@Rule1,@Severity1,@Rule1Desc,@Rule1Mitigation)
	END
	
	--Rule 2: The first character must be a letter
	IF LEFT(@Identifier,1) NOT like '[a-Z]' 
	BEGIN
	     SET @Severity2 = (CASE WHEN @IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END)
		INSERT INTO @retInfo(ViolatedRule,Severity,ViolatedDescription,Mitigation) VALUES (@Rule2,@Severity2,@Rule2Desc,@Rule2Mitigation)
	END

	--Rule 3: No embedded spaces
	IF CHARINDEX(' ',@Identifier)> 0
	BEGIN
	     SET @Severity3 = (CASE WHEN @IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END)
		INSERT INTO @retInfo(ViolatedRule,Severity,ViolatedDescription,Mitigation) VALUES (@Rule3,@Severity3,@Rule3Desc,@Rule3Mitigation)
	END
	
	--Rule 4: Should not use reserved words
	IF EXISTS (SELECT 1 FROM dbo.KeyWordList WHERE KeyWord  = @Identifier)
	BEGIN
	     SET @Severity4 = 'Warning'
		INSERT INTO @retInfo(ViolatedRule,Severity,ViolatedDescription,Mitigation) VALUES (@Rule4,@Severity4,@Rule4Desc,@Rule4Mitigation)
	END

	RETURN 
END