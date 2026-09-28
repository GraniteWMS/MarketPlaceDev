{{#if Scanned}}
  {{
    "EXEC GetLookupData
    @columnNames = \"TrackingEntity_Barcode, TrackingEntity_Qty, MasterItem_Description, MasterItem_Code, Location_Barcode\", 
    @value = @Scanned"
    | dbSelect({Scanned}) 
    | to => returnedData
  }}
  <div class="row g-0">
      <small class="col">Count</small>
      <header id="Count" class="col">{{returnedData.Count}}</header>
  </div>
  <div class="row g-0">
      <small class="col">Total Qty</small>
      <header class="col">{{returnedData.reduce((acc, row) => acc + row.TrackingEntity_Qty, 0)}}</header>
  </div>

  <div class="table table-responsive-sm">
    {{returnedData | basicTable({enableSearch:true}) }}
  </div>


{{/if}}