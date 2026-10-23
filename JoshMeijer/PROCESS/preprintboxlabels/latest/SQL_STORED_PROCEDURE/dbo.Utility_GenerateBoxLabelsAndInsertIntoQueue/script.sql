CREATE PROCEDURE [dbo].[Utility_GenerateBoxLabelsAndInsertIntoQueue] (
@NumberOfLabels bigint,
@User varchar(50),
@Printer varchar(50))
AS
BEGIN
DECLARE @Prefix varchar(10)
,@Length bigint
,@NextBarcode bigint
,@DateToQueueLabels datetime = GETDATE()
,@GenerateDate varchar(10) =FORMAT(GETDATE(),'MMddyy')
SELECT @Prefix = [Prefix], @Length = [Length], @NextBarcode = [NextBarcode] + 1 FROM BarcodeMaster
WHERE [Name] = 'BOX'
UPDATE BarcodeMaster
SET NextBarcode = NextBarcode + @NumberOfLabels + 1
WHERE [Name] = 'BOX';
WITH NumberSequence AS
(SELECT @NextBarcode Number
UNION ALL
SELECT Number + 1
FROM NumberSequence WHERE Number < @NumberOfLabels + @NextBarcode - 1)
INSERT INTO LabelPrintQueue (DateQueued, LabelFormat, LabelParameter1, QuantityofLabels, [Status], [User], [Printer])
SELECT @DateToQueueLabels, 'BOX',  CONCAT(@Prefix, REPLICATE('0', @Length - LEN(Number)), Number), 1, 'ENTERED', @User, @Printer
FROM NumberSequence
OPTION(MAXRECURSION 500)
END
