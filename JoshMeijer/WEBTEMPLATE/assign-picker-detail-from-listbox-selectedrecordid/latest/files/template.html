{{#if Type}}
    <div>
        <small>Type</small>
        <header class="gn-float-right">{{Type}}</header>
    </div>
    <hr /> 
	{{#if Document}}
        <div>
            <small>Document</small>
            <header class="gn-float-right">{{Document}}</header>
        </div>
        <hr />     
		{{#if AssignTo}}
            <div>
                <small>User Selected</small>
                <header class="gn-float-right">{{AssignTo}}</header>
            </div>	
            <hr /> 
        {{/if}} 
    {{/if}}    
{{/if}}


{{#if Document && Type && AssignTo}}
	{{#if Type === "ASSIGN"}}
        {{"SELECT ID, Line, Code, Description, ToPick, AssignedTo 
           FROM Webtemplate_VW_AssignPicker_SelectedRecordID
           WHERE Number = @Document 
           ORDER BY IsAssigned, AssignedTo, Line 
          "|> dbSelect({Document}) |> to => listDetails
        }} 
    {{else}} 
         {{"SELECT ID, Line, Code, Description, ToPick, AssignedTo
           FROM Webtemplate_VW_AssignPicker_SelectedRecordID
           WHERE Number = @Document 
           AND AssignedTo = @AssignTo
           ORDER BY Line 
          "|> dbSelect({Document,AssignTo}) |> to => listDetails  
         }}    
	{{/if}}

    
    {{#if !listDetails}}
    	<p>No records for selection </p>
    {{else}}
    	{{ listDetails |> multiSelectTable({ valueColumn: "ID", enableSearch: true }) }}
    {{/if}}
{{/if}}