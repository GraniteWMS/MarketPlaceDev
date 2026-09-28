CREATE VIEW WebTemplateReceiveReturnDocument
AS
SELECT	Number, ERPIdentification
FROM	Document 
WHERE	Type = 'RECEIVING'
		AND Status IN ('RELEASED', 'ENTERED')
		AND Number LIKE 'R-%'