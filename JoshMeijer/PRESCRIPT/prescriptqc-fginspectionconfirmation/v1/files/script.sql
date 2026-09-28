CREATE PROCEDURE  [dbo].[PrescriptQC_FGInspectionConfirmation] (
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
	DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document')
	DECLARE @User varchar(50) = (SELECT Value FROM @input WHERE Name = 'User')
	DECLARE @MI_ID Bigint = (SELECT TOP 1 DocumentDetail.Item_id FROM Document INNER JOIN DocumentDetail ON Document.ID = DocumentDetail.Document_id WHERE DocumentDetail.Type = 'Output')
	DECLARE @MI_Code varchar(50) = (SELECT Code FROM MasterItem WHERe ID = @MI_ID)
	DECLARE @MI_Description varchar(250) = (SELECT [Description] FROM MasterItem WHERE ID = @MI_ID)
	DECLARE @Batch varchar(50) = (SELECT Value FROM @input WHERE Name = 'Batch')
	DECLARE @Gauge varchar(50) = (SELECT Value FROM @input WHERE Name = 'Gauge')
	DECLARE @Tolerance varchar(50) = (SELECT Value FROM @input WHERE Name = 'Tolerance')
	DECLARE @Value_x varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_x')
	DECLARE @Value_y varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_y')
	DECLARE @Value_Flange varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_Flange')
	DECLARE @Value_HolePosition varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_HolePosition')
	DECLARE @Value_HoleSpacing varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_HoleSpacing')
	DECLARE @Value_HoleCentering varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_HoleCentering')
	DECLARE @Value_Length varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_Length')
	DECLARE @Value_Angle varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_Angle')
	DECLARE @Value_PaintCoating varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_PaintCoating')
	DECLARE @Value_AnodizedCoating varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_AnodizedCoating')
	DECLARE @Value_PowderCoating varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_PowderCoating')
	DECLARE @Value_AcceptReject varchar(50) = (SELECT Value FROM @input WHERE Name = 'Value_AcceptReject')
	DECLARE @Comment varchar(250) = (SELECT Value FROM @input WHERE Name = 'Comment')
	INSERT INTO QC_FGInspection (Document,[User], Code, Description,Batch, Gauge,Tolerance,Value_x,Value_y,Value_Flange,Value_HolePosition,Value_HoleSpacing,Value_HoleCentering,
	Value_Length,Value_PaintCoating,Value_AnodizedCoating,Value_PowderCoating,Value_AcceptReject,Comment,RecordDate)
	SELECT @Document,@User, @MI_Code, @MI_Description, @Batch, @Gauge,@Tolerance,@Value_x,@Value_y,@Value_Flange,@Value_HolePosition,@Value_HoleSpacing,@Value_HoleCentering,
	@Value_Length,@Value_PaintCoating,@Value_AnodizedCoating,@Value_PowderCoating,@Value_AcceptReject, @Comment, getdate()
	SELECT @message = 'Quality form data Saved'
	SELECT @valid = 1
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
