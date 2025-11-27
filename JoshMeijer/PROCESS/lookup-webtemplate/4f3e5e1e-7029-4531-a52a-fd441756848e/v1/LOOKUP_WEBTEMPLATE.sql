-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: LOOKUP_WEBTEMPLATE
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Scanned','Scan a Barcode',0, 'True','True','',1,'LOOKUP_WEBTEMPLATE','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Result','Press Enter to Restart',1, 'True','False','',0,'LOOKUP_WEBTEMPLATE','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOOKUP_WEBTEMPLATE','GENERIC LOOKUP','CUSTOM', '','False','False','
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


{{/if}}')

-- =============================================
-- END OF SCRIPT
-- =============================================
