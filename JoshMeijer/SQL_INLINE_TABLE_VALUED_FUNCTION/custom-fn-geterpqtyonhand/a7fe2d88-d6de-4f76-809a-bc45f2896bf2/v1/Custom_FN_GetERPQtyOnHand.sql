
CREATE FUNCTION [dbo].[Custom_FN_GetERPQtyOnHand] (@ItemCode Varchar(100),@ItemLocation varchar(100))
RETURNS TABLE AS
RETURN
(
    SELECT TOP 1 *
    FROM ERP_StockOnHand
    WHERE ITEMNO = @ItemCode and LOCATION = @ItemLocation
        -- AND active = 1
)
