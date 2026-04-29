CREATE VIEW Webtemplate_VW_AssignPicker_SelectedRecordID
AS
SELECT  Document.Number,
        DocumentDetail.ID, 
        DocumentDetail.LineNumber as [Line], 
        MasterItem.Code, 
        MasterItem.[Description], 
        CAST(CASE WHEN Document.[Status] IN ('COMPLETE','CANCELLED') 
                OR DocumentDetail.Completed = 1 
                OR DocumentDetail.Cancelled = 1 THEN DocumentDetail.ActionQty 
                ELSE DocumentDetail.Qty END - DocumentDetail.ActionQty AS decimal(19,0)) as [ToPick], 
        ISNULL(OFV.[AssignedTo],'None') [AssignedTo],
        IIF(OFV.[AssignedTo] IS NULL, 0, 1) IsAssigned
FROM Document 
INNER JOIN DocumentDetail ON Document.ID = DocumentDetail.Document_id 
INNER JOIN MasterItem ON DocumentDetail.Item_id = MasterItem.ID 
OUTER APPLY ( SELECT OFV_DD.[Value] AS [AssignedTo]
                FROM OptionalFieldValues_DocumentDetail OFV_DD 
                INNER JOIN OptionalFields OFS 
                        ON OFS.ID = OFV_DD.OptionalField_id 
                        AND OFS.isActive = 1 
                        AND OFS.AppliesTo = 'DOCUMENTDETAIL' 
                        AND OFS.Name = 'AssignedTo' 
                WHERE OFV_DD.BelongsTo_id = DocumentDetail.ID 
            ) OFV 
          
