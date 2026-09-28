CREATE PROCEDURE [dbo].[Job_PrePrintPalletLabels]
AS
BEGIN
DECLARE @BarcodesToPrint varchar(4000)
,@Printer varchar(50)
,@UserID bigint
,@success [int]
,@message [nvarchar](max)
,@Counter bigint = 1
,@GroupCount bigint
,@CurrentDate datetime = GETDATE()
DECLARE @LabelsToPrint TABLE
(
ID bigint IDENTITY(1, 1),
BarcodesToPrint varchar(4000),
Printer varchar(50),
UserID bigint)
INSERT INTO @LabelsToPrint(BarcodesToPrint, Printer, UserID)
SELECT
STRING_AGG([LabelParameter1],','),
[Printer],
U.ID
FROM LabelPrintQueue
INNER JOIN Users U ON LabelPrintQueue.[User] = U.[Name]
WHERE [Status] NOT IN ('PRINTED', 'FAILED') AND LabelFormat = 'BOX'
GROUP BY
Printer,
U.ID
SELECT @GroupCount = MAX(ID) FROM @LabelsToPrint
WHILE @Counter <= @GroupCount
BEGIN
      SELECT @BarcodesToPrint = BarcodesToPrint,
      @Printer = Printer,
      @UserID = UserID
      FROM @LabelsToPrint
      WHERE ID = @Counter
      EXEC [dbo].[clr_PrintLabel]
            NULL,
            @BarcodesToPrint,
            'Pallet.zpl',
            1,
            @Printer,
            'PALLET',
            @UserID,
            @success OUTPUT,
            @message OUTPUT
      UPDATE LabelPrintQueue
      SET [Status] = IIF(@success = 1, 'PRINTED', 'FAILED'),
      [DatePrinted] = @CurrentDate,
      ResponseComment = CONVERT(VARCHAR(200), @message)
      WHERE [LabelParameter1] IN (SELECT [Value] FROM STRING_SPLIT(@BarcodesToPrint, ','))
      SET @Counter += 1
END
END
