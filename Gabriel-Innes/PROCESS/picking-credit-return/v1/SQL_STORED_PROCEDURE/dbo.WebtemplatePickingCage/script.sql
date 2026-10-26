CREATE PROCEDURE [dbo].[WebtemplatePickingCage]
	@Document varchar(50)
AS
BEGIN  
	IF (@Document LIKE 'AU-%')
		BEGIN 
			SELECT DISTINCT DocumentDetail.Comment AS Cage 
			FROM 
			Document WITH (NOLOCK) LEFT JOIN 
			DocumentDetail WITH (NOLOCK) ON Document.ID = DocumentDetail.Document_id INNER JOIN
			DocumentDetail FragmanetLines ON DocumentDetail.ID = CONVERT(bigint, FragmanetLines.ERPIdentification)
			WHERE Document.Type = 'ORDER' AND FragmanetLines.Completed = 0 AND Number = @Document
		END
	ELSE
		BEGIN 
			SELECT DISTINCT Comment AS Cage 
			FROM 
			Document WITH (NOLOCK) LEFT JOIN 
			DocumentDetail WITH (NOLOCK) ON Document.ID = DocumentDetail.Document_id
			WHERE Document.Type = 'ORDER' AND DocumentDetail.Completed = 0 AND Number = @Document
		END
END
