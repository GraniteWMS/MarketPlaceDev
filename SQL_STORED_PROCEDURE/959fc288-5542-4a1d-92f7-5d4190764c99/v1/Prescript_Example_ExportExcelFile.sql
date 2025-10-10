CREATE PROCEDURE [dbo].[Prescript_Example_ExportExcelFile] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max), 
  Value varchar(max) 
  )

SET NOCOUNT ON;
DECLARE @valid bit
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 


DECLARE @tableName varchar(50) 
DECLARE @offset int
DECLARE @limit int
DECLARE @fileDestinationPath varchar(100)
DECLARE @filetype varchar(20)
DECLARE @orderByList varchar(200)
DECLARE @filters varchar(200)
DECLARE @responseCode int
DECLARE @responseJson varchar(max)

SELECT @tableName = 'API_QueryStockTotals'
SELECT @fileDestinationPath = 'D:\\Granite WMS\\V5 Demo\\StockInFreezer.csv'
SELECT @filetype = 'CSV'

SET @orderByList = dbo.export_AddOrderBy(@OrderByList, 'Type', 'DESC')
SET @orderByList = dbo.export_AddOrderBy(@OrderByList, 'Code', 'ASC')
SET @filters = dbo.export_AddFilter(@Filters, 'Category', 'Equal', 'Freezer')
SET @filters = dbo.export_AddFilter(@Filters, 'Qty', 'GreaterThan', '0')

SET @offset = 0
SET @limit = 500

EXEC clr_TableExport 
	@tableName
	,@filters
	,@offset
	,@limit
	,@orderByList
	,@fileDestinationPath 
	,@fileType
	,@responseCode OUTPUT
	,@responseJson OUTPUT

IF @responseCode = 200
BEGIN
	SELECT @valid = 1
	SELECT @message = 'File exported successfully'
END	
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = @responseJSON
END

INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput

SELECT * FROM @Output


