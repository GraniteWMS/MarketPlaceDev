CREATE FUNCTION [dbo].[FN_MasterItem_Search]
(
    @searchValue NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT 
		   M.Code 
		  ,M.Description
		  ,CASE WHEN M.EnforceBatchNumber = 0 THEN 'False' ELSE 'True' END [Batch] 
		  ,CASE WHEN M.EnforceExpiryDate = 0 THEN 'False' ELSE 'True' END [Expiry] 
		  ,CASE WHEN M.EnforceSerialNumber = 0 THEN 'False' ELSE 'True' END [Serial]
    FROM MasterItem M
    WHERE M.IsActive = 1
    AND NOT EXISTS
    (
        SELECT 1
        FROM STRING_SPLIT(@searchValue, ' ') S
        WHERE LTRIM(RTRIM(S.value)) <> ''
        AND
        (
            M.Description NOT LIKE '%' + LTRIM(RTRIM(S.value)) + '%'
            AND
            M.Code        NOT LIKE '%' + LTRIM(RTRIM(S.value)) + '%'
        )
    )
);
