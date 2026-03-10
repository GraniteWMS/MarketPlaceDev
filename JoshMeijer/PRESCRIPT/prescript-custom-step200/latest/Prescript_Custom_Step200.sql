
CREATE PROCEDURE [dbo].[Prescript_Custom_Step200] (
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


DECLARE @userName nvarchar(max) = 'TEST'
DECLARE @password nvarchar(max) = 'TEST'



EXECUTE [dbo].[clr_AuthenticateUser] 
   @userName
  ,@password
  ,@valid OUTPUT
  ,@message OUTPUT


INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput

SELECT * FROM @Output
