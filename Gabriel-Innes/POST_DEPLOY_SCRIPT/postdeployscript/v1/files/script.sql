INSERT INTO [Type] (Name, Description, isActive, AppliesTo)
SELECT 'PACKAGING','PACKAGING',1,'MASTERITEM'
WHERE NOT EXISTS (
    SELECT 1 FROM [Type]
    WHERE Name = 'PACKAGING' 
    AND AppliesTo = 'MASTERITEM'
)