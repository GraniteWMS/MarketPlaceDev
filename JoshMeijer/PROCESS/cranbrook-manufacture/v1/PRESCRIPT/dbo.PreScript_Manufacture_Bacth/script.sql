CREATE PROCEDURE [dbo].[PreScript_Manufacture_Bacth] (
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
DECLARE @numberOfMonths int
DECLARE @expiryDate date
DECLARE @todayDate date
DECLARE @finalDate varchar(20)
DECLARE @mix varchar(20)
DECLARE @batch varchar(20)
DECLARE @batchFinal varchar(20)
DECLARE @masterItem varchar(30)
DECLARE @batchFinala varchar(20)
DECLARE @batchFinalb varchar(20)
DECLARE @batchFinalc varchar(20)
DECLARE @batchFinald varchar(20)
DECLARE @batchFinale varchar(20)
DECLARE @batchFinalf varchar(20)
DECLARE @batchFinalg varchar(20)
DECLARE @batchFinalh varchar(20)
SELECT @todayDate = GETDATE()
SELECT @numberOfMonths = @stepInput
SELECT @mix = Value FROM @input WHERE Name = 'Mix'
SELECT @expiryDate = DATEADD(MONTH,@numberOfMonths,@todayDate)
SELECT @masterItem = Value FROM @input WHERE Name = 'MasterItem'
SELECT @finalDate = Convert(varchar, @expiryDate,112)
SELECT @batch = CONCAT(@masterItem, Convert(varchar, @todayDate,112))
If(@mix = 1) or (@mix = 2) or (@mix = 3) or (@mix = 4) or (@mix = 5) or (@mix = 6) or (@mix = 7) or (@mix = 8)
BEGIN
	If(@mix = 1)
	BEGIN
		SELECT @batchFinala = CONCAT(@batch,'A')
		INSERT INTO @Output
		SELECT 'Batch', @batchFinala
	END
	ELSE
	If(@mix = 2)
	BEGIN
		SELECT @batchFinalb = CONCAT(@batch,'B')
		INSERT INTO @Output
		SELECT 'Batch', @batchFinalb
	END
	If(@mix = 3)
	BEGIN
		SELECT @batchFinalc = CONCAT(@batch,'C')
		INSERT INTO @Output
		SELECT 'Batch', @batchFinalc
	END
	ELSE
	If(@mix = 4)
	BEGIN
		SELECT @batchFinald = CONCAT(@batch,'D')
		INSERT INTO @Output
		SELECT 'Batch', @batchFinald
	END
	If(@mix = 5)
	BEGIN
		SELECT @batchFinale = CONCAT(@batch,'E')
		INSERT INTO @Output
		SELECT 'Batch', @batchFinale
	END
	ELSE
	If(@mix = 6)
	BEGIN
		SELECT @batchFinalf = CONCAT(@batch,'F')
		INSERT INTO @Output
		SELECT 'Batch', @batchFinalf
	END
	If(@mix = 7)
	BEGIN
		SELECT @batchFinalg = CONCAT(@batch,'G')
		INSERT INTO @Output
		SELECT 'Batch', @batchFinalg
	END
	If(@mix = 8)
	BEGIN
		SELECT @batchFinalh = CONCAT(@batch,'H')
		INSERT INTO @Output
		SELECT 'Batch', @batchFinalh
	END
END
ELSE
BEGIN
	
	INSERT INTO @Output
	SELECT 'Batch', @batch
END
INSERT INTO @Output
SELECT 'ExpiryDate', @finalDate
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
