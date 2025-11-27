CREATE PROCEDURE [dbo].[ValidateLocation] (
   @LocationIdentifier varchar (50),
   @Exists bit OUTPUT,
   @LocationBarcode varchar (50) OUTPUT
)
AS

SET NOCOUNT ON;

IF EXISTS (SELECT ID FROM [Location] WHERE ([Name] = @LocationIdentifier OR Barcode = @LocationIdentifier) AND isActive = 1)
BEGIN

	SELECT @Exists = 1

	IF NOT EXISTS (SELECT ID FROM [Location] WHERE Barcode = @LocationIdentifier)
	BEGIN

		SELECT @LocationBarcode = Barcode FROM [Location] WHERE [Name] = @LocationIdentifier

	END
	ELSE
	BEGIN

		SELECT @LocationBarcode = @LocationIdentifier

	END

END
ELSE
BEGIN

	SELECT @Exists = 0

END