-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: LOOKUP_WITH_IMAGES
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('LookupValue','LookupValue',1, 'True','True','',2,'LOOKUP_WITH_IMAGES','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirm',2, 'True','True','',1,'LOOKUP_WITH_IMAGES','','{{ "EXEC WebtemplateLookupValue @MasterItem = @LookupValue" | dbScalar({LookupValue}) |> to => URL }}

<img src="{{URL}}"       style="border: 1px solid #000; width:100%; max-width:500px; max-height:500px;">')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOOKUP_WITH_IMAGES','LOOKUP WITH IMAGES','LOOKUP', '','False','False','
{{#if Type && LookupValue}}
    {{#if Type === "MasterItem"}}
        {{var whereClause = "WHERE MasterItem.Code = @LookupValue AND InStock = 1"}}
        {{
            "SELECT TOP 1 Code, Description
            FROM MasterItem 
            WHERE Code = @LookupValue OR FormattedCode = @LookupValue"
            | dbSingle({LookupValue})
            | to => masterItem
        }}
        <div>
            <header>{{masterItem.Code}}</header>
            <small style="-ms-word-wrap: break-word; word-wrap: break-word;">{{masterItem.Description}}</small>
        </div>
    {{else}}
        <div>
            <header>{{Type}}</header>
        </div>
    {{/if}}

    {{#if Type === "Inventory"}}
        {{var whereClause = "WHERE TrackingEntity.Barcode = @LookupValue"}}
    {{/if}}
    {{#if Type === "Location"}}
        {{var whereClause = "WHERE Location.Barcode = @LookupValue AND TrackingEntity.InStock = 1"}}
    {{/if}}
    {{#if Type === "Serial"}}
        {{var whereClause = "WHERE TrackingEntity.SerialNumber = @LookupValue"}}
    {{/if}}
    {{#if Type === "Batch"}}
        {{var whereClause = "WHERE TrackingEntity.Batch = @LookupValue AND InStock = 1"}}
    {{/if}}

    {{
        "SELECT MasterItem.Code, MasterItem.Description, Location.Name LocationName,
        ERPLocation, CarryingEntity.Barcode Pallet, TrackingEntity.InStock,
        TrackingEntity.OnHold, TrackingEntity.StockTake, TrackingEntity.Barcode, Qty, SerialNumber, 
        Batch, ExpiryDate, MasterItem.UOM
        FROM TrackingEntity INNER JOIN
        MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID INNER JOIN
        Location ON TrackingEntity.Location_id = Location.ID LEFT JOIN
        CarryingEntity ON TrackingEntity.BelongsToEntity_id = CarryingEntity.ID " 
        + whereClause
        | dbSelect({LookupValue})
        | to => trackingEntities
    }}

    {{
        "SELECT SUM(Qty)
        FROM TrackingEntity INNER JOIN
        MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID INNER JOIN
        Location ON TrackingEntity.Location_id = Location.ID LEFT JOIN
        CarryingEntity ON TrackingEntity.BelongsToEntity_id = CarryingEntity.ID "
        + whereClause
        | dbScalar({LookupValue})
        | to => sumQty
    }}
    
{{/if}}

{{#if trackingEntities}}
    <div class="row g-0">
        <small class="col">Count</small>
        <header id="Count" class="col">{{trackingEntities.Count}}</header>
    </div>

    
    <div class="row g-0">
        <small class="col">Sum total</small>
        <header class="col">{{sumQty}}</header>
    </div>
{{/if}}

<hr />

{{#if trackingEntities}}
    {{#if trackingEntities.Count > 0}}

        <hr />
        {{#each trackingEntities}}
            {{#if it.InStock}}
                <div>
                    <header class="gn-success">InStock</header>
                </div>
            {{else}}
                <div>
                    <header class="gn-error">Scrapped</header>
                </div>
            {{/if}}

            {{#if it.OnHold}}
                <div>
                    <header class="gn-message">OnHold</header>
                </div>
            {{/if}}

            {{#if it.StockTake}}
                <div>
                    <header class="gn-message">StockTake</header>
                </div>
            {{/if}}

            {{#if Type != "MasterItem"}}
                <div class="row g-0">
                    <header class="col">{{it.Code}}</header>
                </div>
                <div class="row g-0">
                    <small style="-ms-word-wrap: break-word; word-wrap: break-word;">{{it.Description}}</small>
                </div>
            {{/if}}

            {{#if it.Pallet}}
                <div class="row g-0">
                    <small class="col">Pallet</small>
                    <header class="col">{{it.Pallet}}</header>
                </div>
            {{/if}}

            <div class="row g-0">
                <small class="col">Barcode</small>
                <header class="col">{{it.Barcode}}</header>
            </div>

            {{#if Type != "Location"}}
                <div class="row g-0">
                    <small class="col">Location</small>
                    <header class="col">{{it.LocationName}} <small style="font-style:normal">{{it.ERPLocation}}</small></header>
                </div>
            {{/if}}

            <div class="row g-0">
                <small class="col">Qty</small>
                <header class="col">{{it.Qty}} {{it.UOM}}</header>
            </div>

            {{#if it.SerialNumber}}
            <div class="row g-0">
                <small class="col">Serial</small>
                <header class="col">{{it.SerialNumber}}</header>
            </div>
            {{/if}}

            {{#if it.Batch}}
            <div class="row g-0">
                <small class="col">Batch</small>
                <header class="col">{{it.Batch}}</header>
            </div>
            {{/if}}

            {{#if it.ExpiryDate}}
            <div class="row g-0">
                <small class="col">Expiry</small>
                <header class="col">{{it.ExpiryDate}}</header>
            </div>
            {{/if}}
            <hr />
        {{/each}}
    {{/if}}
{{/if}}
')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Type',0, 'True','True','',1,'LOOKUP_WITH_IMAGES','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
