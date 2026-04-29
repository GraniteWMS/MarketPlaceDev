{{ "EXEC WebtemplateLookupValue @MasterItem = @LookupValue" | dbScalar({LookupValue}) |> to => URL }}

<img src="{{URL}}"       style="border: 1px solid #000; width:100%; max-width:500px; max-height:500px;">