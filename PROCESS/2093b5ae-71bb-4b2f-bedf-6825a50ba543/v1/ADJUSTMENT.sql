-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 09:00:53
-- =============================================

-- =============================================
-- SQL OBJECTS (Tables, Views, Functions, etc.)
-- =============================================

-- SQL_STORED_PROCEDURE: PrescriptTest

CREATE PROCEDURE [dbo].[PrescriptTest] (
   @input dbo.ScriptInputParameters READONLY --List of [Name, Value]
)
AS
--##START dont modify
--Return table. Table containing stepnames and values.
--NOTE: also include variable @valid, @message and @stepInput, with there values.
--The Output table is same structure as the ScriptInputParameters the @input
DECLARE @Output TABLE(
  Name varchar(max),  --Name represents the stepname
  Value varchar(max)  --Value the value of the step
  )

SET NOCOUNT ON;

--declare standard variables to be set in return table
DECLARE @valid bit
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' --set your variable to the incoming step input value 
--##END


SELECT @valid = 1
SELECT @message = @stepInput

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

----return values Output
	SELECT * FROM @Output

GO

-- =============================================
-- DATA INSERTS
-- =============================================

-- =============================================
-- END OF SCRIPT
-- =============================================
