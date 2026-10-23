
CREATE PROCEDURE [dbo].[PrescriptGenericQCConfirmation] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE
	  @valid						BIT
	, @message						VARCHAR(MAX)
	, @stepInput					VARCHAR(MAX)
	, @trackingEntityBarcode		VARCHAR(50)
	, @Type							VARCHAR(50)
	, @Comment						VARCHAR(50)
	, @Confirmation					VARCHAR(50)
	, @TrackingEntityLocation		VARCHAR(50)
	, @SendMail						BIT
	, @subject						NVARCHAR(MAX)
	, @templateName					NVARCHAR(MAX)
	, @templateParameters			NVARCHAR(MAX)
	, @toEmailAddresses				NVARCHAR(MAX)
	, @ccEmailAddresses				NVARCHAR(MAX)
	, @bccEmailAddresses			NVARCHAR(MAX)
	, @reportAttachments			NVARCHAR(MAX)
	, @excelAttachments				NVARCHAR(MAX)
	, @fileAttachments				NVARCHAR(MAX)
	, @success						BIT
	, @userName						nvarchar(max)
	, @inventoryIdentifier			nvarchar(max)
	, @locationIdentifier			nvarchar(max)
	, @reference					nvarchar(max)
	, @integrationReference			nvarchar(max)
	, @processName					nvarchar(max)
	, @DocumentNumber				VARCHAR(50)
	, @optionalFieldName			nvarchar(max)
	, @value						nvarchar(max)
	
	, @qcKey                        NVARCHAR(128)
	, @qcPassLocation               VARCHAR(50)
	, @qcValue                      NVARCHAR(20)   
;
SELECT @stepInput					= VALUE FROM @input WHERE [Name] = 'StepInput'
SELECT @trackingEntityBarcode		= VALUE FROM @input WHERE [Name] = 'TrackingEntity'
SELECT @Type						= VALUE FROM @input WHERE [Name] = 'Type'
SELECT @Comment						= VALUE FROM @input WHERE [Name] = 'Comment'
SELECT @Confirmation				= VALUE FROM @input WHERE [Name] = 'Confirmation'
SELECT @userName					= VALUE FROM @input WHERE [Name] = 'User'
SELECT @locationIdentifier			= VALUE FROM @input WHERE [Name] = 'Location' 
SELECT @value						= VALUE FROM @input WHERE [Name] = 'OptionalFieldValue'
SELECT @processName					= CONCAT(@locationIdentifier, 'QC') 
SET @qcPassLocation = @locationIdentifier;
SELECT
	  @inventoryIdentifier			= Barcode
	, @subject						= CONCAT(Batch, ': ', Barcode)
	, @DocumentNumber				= Batch
	, @templateName					= 'QCFailed'
	, @ccEmailAddresses				= ''
	, @bccEmailAddresses			= ''
	, @reference					= ''
	, @integrationReference			= ''
FROM TrackingEntity
WHERE Barcode = @trackingEntityBarcode
IF @locationIdentifier IN ( 'ChemicalAnalysis', 'Casted') 
BEGIN
	SELECT @optionalFieldName		= 'ShortHeatNumber'
END
SELECT @toEmailAddresses = STRING_AGG(Value,';')
FROM SystemStaticData
WHERE [Group] = 'EMAILQC'
SET @templateParameters = dbo.email_AddTemplateParameter(@templateParameters, 'TrackingEntity' , @inventoryIdentifier)
SET @templateParameters = dbo.email_AddTemplateParameter(@templateParameters, 'DocumentNumber', @DocumentNumber)
SET @templateParameters = dbo.email_AddTemplateParameter(@templateParameters, 'Location'      , @locationIdentifier)
SET @templateParameters = dbo.email_AddTemplateParameter(@templateParameters, 'User'          , @userName)
SET @templateParameters = dbo.email_AddTemplateParameter(@templateParameters, 'ProcessName'   , @processName)
IF ISNULL(@Confirmation,'NO') = 'NO'
BEGIN
	SELECT @valid = 1, @message = 'CANCELLED', @SendMail = 0
END
ELSE
BEGIN
	
	
	IF @Type = 'Reject'
	BEGIN
		SELECT @SendMail = 1, @locationIdentifier = 'Reject' 
	END
	
	EXECUTE [dbo].[clr_Move]
		@userName, @inventoryIdentifier, @locationIdentifier,
		@Comment, @reference, @integrationReference, @processName,
		@success OUTPUT, @message OUTPUT
	
	IF @success = 1
	BEGIN
		SET @valid = 1
		
		SET @qcKey = NULL;
		IF UPPER(@qcPassLocation) = 'HEATTREATED'
			SET @qcKey = 'QC_HEATTREATED';
		ELSE IF UPPER(@qcPassLocation) = 'MECHANICALTESTED'
			SET @qcKey = 'QC_MECHANICALTESTED';
		ELSE IF UPPER(@qcPassLocation) = 'MACHINED'
			SET @qcKey = 'QC_MACHINED';
		ELSE IF UPPER(@qcPassLocation) = 'LIQUIDPENETRANTTESTED'
			SET @qcKey = 'QC_LIQUIDPEN';
		ELSE IF UPPER(@qcPassLocation) = 'RADIOGRAPHICTESTED'
			SET @qcKey = 'QC_RADIOGRAPHIC';
		ELSE IF UPPER(@qcPassLocation) = 'CHEMICALANALYSISTESTED'		
			SET @qcKey = 'QC_CHEMICALANALYSIS';
		ELSE IF UPPER(@qcPassLocation) = 'MAGNETICPARTICLETESTED'		
			SET @qcKey = 'QC_MAGNETICTESTED';
		ELSE IF UPPER(@qcPassLocation) = 'IMPACTTESTED'					
			SET @qcKey = 'QC_IMPACTTESTED';
		ELSE IF UPPER(@qcPassLocation) = 'CUSTOMERINSPECTED'					
			SET @qcKey = 'QC_CUSTOMERINSPECTED';
		ELSE IF UPPER(@qcPassLocation) = 'QUALITYCONTROLCHECKED'					
			SET @qcKey = 'QC_QUALITYCONTROLCHECKED';
		
		IF @Type = 'Reject'
			SET @qcValue = 'REJECT';
		ELSE
			SET @qcValue = 'PASS';
		
		IF @qcKey IS NOT NULL
		BEGIN
			EXECUTE [dbo].[clr_TrackingEntityOptionalField]
				   @userName
				  ,@trackingEntityBarcode
				  ,@qcKey
				  ,@qcValue         
				  ,@success OUTPUT
				  ,@message OUTPUT;
		END
		
	END
END
IF ISNULL(@SendMail,0) = 1
BEGIN
	EXEC dbo.clr_TemplateEmail
		@subject, @templateName, @templateParameters,
		@toEmailAddresses, @ccEmailAddresses, @bccEmailAddresses,
		@reportAttachments, @excelAttachments, @fileAttachments,
		@success OUTPUT, @message OUTPUT
END
IF ISNULL(@optionalFieldName, '' ) != '' AND ISNULL(@value, '' ) != ''
BEGIN
	EXEC dbo.clr_TrackingEntityOptionalField 
	   @userName
	  ,@trackingEntityBarcode
	  ,@optionalFieldName
	  ,@value
	  ,@success OUTPUT
	  ,@message OUTPUT
END
IF ISNULL(@Confirmation,'NO') <> 'NO'    
   AND ISNULL(@success,1) = 1           
BEGIN
    IF @Type = 'Reject'
        SET @message = CONCAT('QC ', @qcPassLocation, ' recorded as REJECT for ', @trackingEntityBarcode);
    ELSE
        SET @message = CONCAT('QC ', @qcPassLocation, ' recorded as PASS for ', @trackingEntityBarcode);
END
INSERT INTO @Output SELECT 'Message',  @message
INSERT INTO @Output SELECT 'Valid',    @valid
INSERT INTO @Output SELECT 'StepInput',@stepInput
SELECT * FROM @Output
EXEC [dbo].[custom_post_to_EVOApp] @inventoryIdentifier