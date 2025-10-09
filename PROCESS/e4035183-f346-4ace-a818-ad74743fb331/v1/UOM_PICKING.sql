-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: UOM_PICKING
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',2, 'True','True','',3,'UOM_PICKING','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',2,'UOM_PICKING','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',1, 'True','True','',2,'UOM_PICKING','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','UOM_PICKING','PICKING','PICKING', '','False','False','
{{#if Document}}
    {{
        "SELECT Number, CAST((SUM(ActionQty) / UOMConversion) / (SUM(Qty)  / UOMConversion) * 100 as decimal(19,2)) as Progress, Document.Description, 
        TradingPartnerCode, TradingPartnerDescription, Document.ERPLocation
        FROM Document INNER JOIN
        DocumentDetail ON Document.ID = DocumentDetail.Document_id
        WHERE Number = @Document
        GROUP BY Number, Document.Description, 
        TradingPartnerCode, TradingPartnerDescription, Document.ERPLocation, DocumentDetail.UOMConversion"
        |> dbSingle({Document}) 
        |> to => document
    }}
    {{
        "SELECT LineNumber, Code as ItemCode, DocumentDetail.Completed, CAST(ISNULL(ActionQty / UOMConversion, 0) / (Qty / UOMConversion) * 100 as int) as ActionCompletion,
        CAST(ActionQty / UOMConversion as decimal(19,2)) ActionQty, CAST(Qty / UOMConversion as decimal(19,2)) Qty, MasterItem.Description ItemDescription, DocumentDetail.UOM, FromLocation, IntransitLocation,
        ToLocation, Comment, Instruction, SerialNumber, Batch, ExpiryDate
        FROM Document INNER JOIN
        DocumentDetail ON Document.ID = DocumentDetail.Document_id INNER JOIN
        MasterItem ON DocumentDetail.Item_id = MasterItem.ID
        WHERE Number = @Document"
        |> dbSelect({Document}) 
        |> to => documentDetails
    }}
    {{#if document.Number}}
    <div>
        <small>Document</small>
        <header class="gn-float-right">
            <p style="display:inline">{{document.Number}}</p>
            <p style="font-weight:200;display:inline">{{document.Progress}}% completed</p>
        </header>
    </div>
    {{/if}}

    {{#if document.Description}}
    <div>
        <small>Description</small>
        <header class="gn-float-right">{{document.Description}}</header>
    </div>
    {{/if}}

    {{#if document.TradingPartnerCode}}
    <div>
        <small>Trading Partner</small>
        <header class="gn-float-right">{{document.TradingPartnerCode}} {{document.TradingPartnerDescription}}</header>
    </div>
    {{/if}}

    {{#if document.ERPLocation}}
    <div>
        <small>ERPLocation</small>
        <header class="gn-float-right">{{document.ERPLocation}}</header>
    </div>
    {{/if}}
{{/if}}

{{#if Location}}
    {{
        "SELECT TOP 1 Name 
        FROM Location 
        WHERE Barcode = @Location OR Name = @Location"
        | dbSingle({Location})
        |> to => location
    }}
    <div>
        <small>Picking Location</small>
        <header class="gn-float-right">{{location.Name}}</header>
    </div>
    <hr />
{{/if}}

{{#if TrackingEntity}}
    {{
        "SELECT ID FROM TrackingEntity WHERE Barcode = @TrackingEntity" 
        | dbExists({TrackingEntity}) |> to => isTrackingEntity
    }}
    {{
        "SELECT ID FROM CarryingEntity WHERE Barcode = @TrackingEntity" 
        | dbExists({TrackingEntity}) |> to => isCarryingEntity
    }}
{{/if}}

{{#if TrackingEntity && isTrackingEntity}}
    {{
        "SELECT TOP 1 MasterItem.Code, MasterItem.Description, 
        Location.Name LocationName, Location.ERPLocation, CarryingEntity.Barcode Pallet,
        TrackingEntity.Barcode, Qty, SerialNumber, Batch, ExpiryDate 
        FROM TrackingEntity INNER JOIN
        MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID INNER JOIN
        Location ON TrackingEntity.Location_id = Location.ID LEFT JOIN
        CarryingEntity ON TrackingEntity.BelongsToEntity_id = CarryingEntity.ID
        WHERE TrackingEntity.Barcode = @TrackingEntity"
        |> dbSingle({TrackingEntity}) 
        |> to => trackingEntity
    }}
    <div>
        <header id="_masterItemCode">{{trackingEntity.Code}}</header>
    </div>
    <div>
        <small id="_masterItemDescription" style="-ms-word-wrap: break-word; word-wrap: break-word;">{{trackingEntity.Description}}</small>
    </div>

    {{#if trackingEntity.Pallet}}
        <div>
            <small>Pallet</small>
            <header id="_trackingEntityPallet" class="gn-float-right">{{trackingEntity.Pallet}}</header>
        </div>
    {{/if}}
    <div>
        <small>Barcode</small>
        <header id="_trackingEntityBarcode" class="gn-float-right">{{trackingEntity.Barcode}}</header>
    </div>
    <div>
        <small>Location</small>
        <header id="_locationName" class="gn-float-right">{{trackingEntity.LocationName}} <small style="font-style:normal">{{trackingEntity.ERPLocation}}</small></header>
    </div>
    <div>
        <small>Qty</small>
        <header id="_trackingEntityQty" class="gn-float-right">{{trackingEntity.Qty}}</header>
    </div>
    <hr />
    {{#if trackingEntity.SerialNumber}}
        <div>
            <small>Serial</small>
            <header id="_trackingEntitySerial" class="gn-float-right">{{trackingEntity.SerialNumber}}</header>
        </div>
    {{/if}}
    {{#if trackingEntity.Batch}}
        <div>
            <small>Batch</small>
            <header id="_trackingEntityBatch" class="gn-float-right">{{trackingEntity.Batch}}</header>
        </div>
    {{/if}}
    {{#if trackingEntity.ExpiryDate}}
        <div>
            <small>Expiry</small>
            <header id="_trackingEntityExpiry" class="gn-float-right">{{trackingEntity.ExpiryDate}}</header>
        </div>
    {{/if}}
{{/if}}

{{#if TrackingEntity && isCarryingEntity}}
    {{var CarryingEntity = TrackingEntity}}
    {{
        "SELECT TrackingEntity.Barcode as Barcode, TrackingEntity.Qty, MasterItem.Code, MasterItem.Description,
        TrackingEntity.SerialNumber, TrackingEntity.Batch, TrackingEntity.ExpiryDate, Location.Name as Location, Location.ERPLocation as ERPLocation
        FROM TrackingEntity INNER JOIN
        CarryingEntity ON TrackingEntity.BelongsToEntity_id = CarryingEntity.ID INNER JOIN
        MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID INNER JOIN
        Location ON TrackingEntity.Location_id = Location.ID
        WHERE CarryingEntity.Barcode = @CarryingEntity"
        |> dbSelect({CarryingEntity}) 
        |> to => trackingEntities
    }}

    <div>
        <small>Pallet</small>
        <a style="font-weight:700" role="button" data-bs-toggle="collapse" data-bs-target="#collapseExample" href="#collapseExample" aria-expanded="false" aria-controls="collapseExample">
            {{CarryingEntity}}
        </a>
    </div>

    <div class="collapse" id="collapseExample">
        {{#if trackingEntities.Count > 0}}
            <div>
                <small>Location</small>
                <header class="gn-float-right">{{trackingEntities[0].Location + " "}} <small style="font-style:normal">{{trackingEntities[0].ERPLocation}}</small></header>
            </div>
            <hr />
            {{#each trackingEntities}}
                <div>
                    <small>{{it.Barcode}}</small>
                    <header class="gn-float-right">{{it.Qty}}</header>
                </div>
                <div>
                    <header>{{it.Code}}</header>
                    <small>{{it.Description}}</small>
                </div>
                {{#if it.SerialNumber}}
                <div>
                    <small>Serial</small>
                    <header class="gn-float-right">{{it.SerialNumber}}</header>
                </div>
                {{/if}}
                {{#if it.Batch}}
                <div>
                    <small>Batch</small>
                    <header class="gn-float-right">{{it.Batch}}</header>
                </div>
                {{/if}}
                {{#if it.ExpiryDate}}
                <div>
                    <small>Expiry</small>
                    <header class="gn-float-right">{{it.ExpiryDate}}</header>
                </div>
                {{/if}}
                <hr />
            {{/each}}
        {{/if}}
    </div>
{{/if}}

{{#if Comment}}
    <div>
        <small>Comment</small>
        <header class="gn-float-right" style="font-style: italic">{{Comment}}</header>
    </div>
{{/if}}

{{#if IntegrationReference}}
    <div>
        <small>Integration Reference</small>
        <header class="gn-float-right" style="font-style: italic">{{IntegrationReference}}</header>
    </div>
{{/if}}

{{#if Reference}}
    <div>
        <small>Reference</small>
        <header class="gn-float-right" style="font-style: italic">{{Reference}}</header>
    </div>
{{/if}}

<hr />

{{#if documentDetails }}
    {{#if documentDetails.Count > 0 }}
    <ul class="list-group" style="padding: 0 !important;margin: 0 !important;">
        {{#each documentDetail in documentDetails}}
        <li class="list-group-item" style="position:inherit;padding: 0 !important;margin: 0 !important;">
            <div class="d-flex justify-content-between">
                <h6 class="mb-1"><p style="font-weight:300;display:inline">({{documentDetail.LineNumber}})</p>{{documentDetail.ItemCode}}</h6>
                <div class="progress" style="height: inherit;width:110px;float:right;
                    {{#if documentDetail.Completed}}background-color:#008CC9;{{/if}}">
                    <div class="progress-bar" role="progressbar" style="font-size: medium;text-align:start; overflow: visible;width: {{documentDetail.ActionCompletion}}%;background-color: #008CC9;color: black;">
                        {{documentDetail.ActionQty}}-{{documentDetail.Qty}}
                    </div>
                </div>
            </div>
            <small class="list-group-item-text" style="-ms-word-wrap: break-word; word-wrap: break-word;">{{documentDetail.ItemDescription}}</small>
            <span style="float:right;position:inherit;width:110px;border-radius:8px;">{{documentDetail.UOM}}</span>

            {{#if documentDetail.FromLocation}}
            <header class="list-group-item-text nopadding">
                <p style="font-weight:100; display:inline">From Location</p>
                <p style="font-weight:600; display:inline; word-wrap: break-word;">{{documentDetail.FromLocation}}</p>
            </header>
            {{/if}}
            
            {{#if documentDetail.IntransitLocation}}
            <header class="list-group-item-text nopadding">
                <p style="font-weight:100; display:inline">Transit Location</p>
                <p style="font-weight:600; display:inline; word-wrap: break-word;">{{documentDetail.IntransitLocation}}</p>
            </header>
            {{/if}}

            {{#if documentDetail.ToLocation}}
            <header class="list-group-item-text nopadding">
                <p style="font-weight:100; display:inline">To Location</p>
                <p style="font-weight:600; display:inline; word-wrap: break-word;">{{documentDetail.ToLocation}}</p>
            </header>
            {{/if}}
            
            {{#if documentDetail.Comment}}
            <header class="list-group-item-text nopadding">
                <p style="font-weight:100; display:inline">Comment </p>
                <p style="font-weight:600; font-style:italic;display:inline;word-wrap: break-word;">{{documentDetail.Comment}}</p>
            </header>
            {{/if}}
            
            {{#if documentDetail.Instruction}}
            <header class="list-group-item-text nopadding">
                <p style="color: White; background-color:#7BB72E; font-weight:400;display:inline;word-wrap: break-word;">{{documentDetail.Instruction}}</p>
            </header>
            {{/if}}
            
            {{#if documentDetail.SerialNumber}}
            <header class="list-group-item-text nopadding">
                <p style="display:inline">Serial </p>
                <p style="display:inline">{{documentDetail.SerialNumber}}</p>
            </header>
            {{/if}}
            
            {{#if documentDetail.Batch}}
            <header class="list-group-item-text nopadding">
                <p style="display:inline">Batch </p>
                <p style="display:inline">{{documentDetail.Batch}}</p>
            </header>
            {{/if}}
            
            {{#if documentDetail.ExpiryDate}}
            <header class="list-group-item-text nopadding">
                <p style="display:inline">Expiry </p>
                <p style="display:inline">{{documentDetail.ExpiryDate}}</p>
            </header>
            {{/if}}
        </li>
        {{/each}}
    </ul>
    {{/if}}
{{/if}}')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'UOM_PICKING','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
