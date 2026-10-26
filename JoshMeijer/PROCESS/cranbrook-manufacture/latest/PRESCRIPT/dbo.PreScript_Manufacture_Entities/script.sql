CREATE PROCEDURE [dbo].[PreScript_Manufacture_Entities] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE 
    @Document VARCHAR(50),
    @Location VARCHAR(50),
    @Mix VARCHAR(50),
    @MasterItem VARCHAR(50),
    @Months VARCHAR(50)
SELECT @Document   = Value FROM @input WHERE Name = 'Document';
SELECT @Location   = Value FROM @input WHERE Name = 'Location';
SELECT @Mix        = Value FROM @input WHERE Name = 'Mix';
SELECT @MasterItem = Value FROM @input WHERE Name = 'MasterItem';
SELECT @Months     = Value FROM @input WHERE Name = 'Months';
IF ISNULL(@Document, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Document number is missing.';
    GOTO CompleteReturn;
END;
IF ISNULL(@Location, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Location is missing.';
    GOTO CompleteReturn;
END;
IF ISNULL(@Mix, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Mix is missing.';
    GOTO CompleteReturn;
END;
IF ISNULL(@MasterItem, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Master Item is missing.';
    GOTO CompleteReturn;
END;
IF ISNULL(@Months, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Months value is missing.';
    GOTO CompleteReturn;
END;
IF @Mix NOT IN ('0', '1', '2', '3', '4', '5', '6', '7', '8')  
BEGIN
    SET @valid = 0;
    SET @message = CONCAT('Invalid Mix value: ', @Mix);
    GOTO CompleteReturn;
END;
IF @Months NOT IN ('4', '6', '9', '12', '18', '24')  
BEGIN
    SET @valid = 0;
    SET @message = CONCAT('Invalid Months value: ', @Months);
    GOTO CompleteReturn;
END;
SET @valid = 1;
SET @message = '';
CompleteReturn:
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
