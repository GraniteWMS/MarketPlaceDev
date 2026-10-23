
CREATE PROCEDURE [dbo].[PrescriptPackMasterItem] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )

SET NOCOUNT ON;

DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 

DECLARE @sql varchar(max)
DECLARE @OrderBy varchar(max)
DECLARE @html varchar(max) = ''

DECLARE @MasterItemCode varchar(max)
SELECT @MasterItemCode = @stepInput
DECLARE @AliasConversion DECIMAL(19,0) = 1
DECLARE @MasterItem_id Bigint
DECLARE @MasterItemDescription varchar(255)
DECLARE @CarryingEntity varchar(50) = (SELECT Value FROM @input WHERE Name = 'CarryingEntity')
IF @CarryingEntity = 'New' 
	SELECT TOP 1 @CarryingEntity =  Barcode FROM CarryingEntity ORDER BY ID DESC

IF EXISTS(SELECT * FROM MasterItemAlias_View WHERE Code = @stepInput)
BEGIN
	SELECT @MasterItem_id = MasterItem_id, @AliasConversion= Conversion FROM MasterItemAlias_View WHERE Code = @stepInput
	SELECT @MasterItemCode = UPPER(Code) FROM MasterItem WHERE ID = @MasterItem_id
	SELECT @stepInput = @MasterItemCode
	
	

END

IF EXISTS(SELECT ID FROM MasterItem WHERE Code = @MasterItemCode)
BEGIN
	

	SELECT @MasterItem_id = ID, @MasterItemDescription = [Description] FROM MasterItem WHERE Code = @MasterItemCode
	SELECT @valid = 1
	SELECT @message = 'Item is:' + @MasterItemDescription
	SELECT @html = '<br>'
END
ELSE
BEGIN
	
	DECLARE @rows varchar(MAX) = ''
	DECLARE @code varchar(30)
	DECLARE @description varchar(100)
	
		DECLARE tmp CURSOR LOCAL FOR
		SELECT  [Code], [Description]
		
		FROM MasterItem WHERE  isActive = 1 and CHARINDEX(@StepInput,Code,1) >=1
		OPEN tmp
		FETCH NEXT FROM tmp INTO @code, @description

		WHILE @@FETCH_STATUS = 0

		BEGIN
			SELECT @rows = CONCAT(@rows, '<tr>
											<td class="code">', @code, '</td><td>', @description, '</td>
										</tr>')
		
			FETCH NEXT FROM tmp INTO @code, @description
		END
		CLOSE tmp
		DEALLOCATE tmp	

		SELECT @html =  CONCAT('<style>
			table, input {width: 100%;}
			input {outline: none; border: none;}
			table, th, td {border: 1px solid black;}
			.empty { background-color: rgb(255,173,102); }
			.code:hover { cursor: pointer; background-color: lightblue;}
			#descripInput {
					background-image: url("https://cdn2.iconfinder.com/data/icons/font-awesome/1792/search-512.png");
					background-position: -2px -2px;
					background-size: contain;
					background-repeat: no-repeat;
				  width: 95%;
				  font-size: 16px;
				  padding: 12px 20px 12px 42px;
				  border: 1px solid #ddd;
				  margin-bottom: 12px;
				}
			</style>
			<head><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"></head>
										<br>
										<input type="text" id="descripInput" onkeyup="searchFunction()" placeholder="Search description.." title="Type in a description">
										<table id="myTable" class="table table-bordered"><tr style="background-color:LightGrey;"><th>Item Code</th><th>Description</th></tr>',
										@rows, 
										'</table><br><br>
				<script>

					function searchFunction() 
					{
						  var input, filter, table, tr, td, i, txtValue;
						  input = document.getElementById("descripInput");
						  filter = input.value.toUpperCase();
						  table = document.getElementById("myTable");
						  tr = table.getElementsByTagName("tr");
						  for (i = 0; i < tr.length; i++) {
							td = tr[i].getElementsByTagName("td")[1];
							if (td) {
							  txtValue = td.textContent || td.innerText;
							  if (txtValue.toUpperCase().indexOf(filter) > -1) {
								tr[i].style.display = "";
							  } else {
								tr[i].style.display = "none";
							  }
							}       
						  }
					}
					$(".code").click(function(e) {	//$("#textBox").val(e.target.id);
													$("#textBox").val(e.target.innerHTML);	
												});
				</script>')


	SELECT @valid = 0
	SELECT @message = 'The Code Scanned is not an Alias or an Item Code -enter an Item Code or try a different UPC'
END

INSERT INTO @Output
SELECT 'Instruction', @html


INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput

SELECT * FROM @Output

