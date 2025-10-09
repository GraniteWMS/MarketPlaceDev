-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: CARRYINGENTITY_CONTENTS_LOOKUP
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirm',1, 'True','True','',0,'CARRYINGENTITY_CONTENTS_LOOKUP','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Barcode','Carrying Entity Barcode',0, 'True','True','',1,'CARRYINGENTITY_CONTENTS_LOOKUP','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','CARRYINGENTITY_CONTENTS_LOOKUP','CARRYINGENTITY_CONTENTS_LOOKUP','CUSTOM', '','False','False','
{{#if Barcode}}
    <div class="row g-0">
        <small class="col">CarryingEntity</small>
        <header class="col">{{Barcode}}</header>
    </div>

    {{
        "EXEC WebtemplateCarryingEntityLookup @Barcode = @Barcode" 
        | dbSelect({Barcode})
        | to => trackingEntities
    }}

    {{
        "SELECT	DISTINCT Location.Name
        FROM	CarryingEntity  
                INNER JOIN Location ON CarryingEntity.Location_id = Location.ID
        WHERE CarryingEntity.Barcode = @Barcode"
        | dbScalar({Barcode})
        | to => Location

    }}

    <div class="row g-0">
        <small class="col">Location</small>
        <header class="col">{{Location}}</header>
    </div>

{{/if}}

{{#if trackingEntities}}
    <div class="row g-0">
        <small class="col">Count</small>
        <header id="Count" class="col">{{trackingEntities.Count}}</header>
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
                    <header class="gn-error">NonStock</header>
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


            <div class="row g-0">
                <small class="col">MasterItemCode</small>
                <header class="col">{{it.Code}}</header>
            </div>

            <div class="row g-0">
                <small class="col">MasterItemDescription</small>
                <header class="col">{{it.Description}}</header>
            </div>

            <div class="row g-0">
                <small class="col">Barcode</small>
                <header class="col">{{it.TrackingEntityBarcode}}</header>
            </div>

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

-- =============================================
-- END OF SCRIPT
-- =============================================
