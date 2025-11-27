-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: REINSTATE_TRACKINGENTITY
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirm','Confirm',1, 'True','True','',0,'REINSTATE_TRACKINGENTITY','','{{#if TrackingEntity}}
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
{{/if}}')


-- ProcessStepsLookup_0
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('1','YES','REINSTATE_TRACKINGENTITY', 'Confirm')


-- ProcessStepsLookup_1
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('0','NO','REINSTATE_TRACKINGENTITY', 'Confirm')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','REINSTATE_TRACKINGENTITY','REINSTATE TRACKINGENTITY','CUSTOM', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',0, 'True','True','',1,'REINSTATE_TRACKINGENTITY','PrescriptReinstateTrackingEntityTrackingEntity','')


-- ProcessStep_200
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Step200','Step200',200, 'True','True','',0,'REINSTATE_TRACKINGENTITY','PrescriptReinstateTrackingEntityStep200','')


-- =============================================
-- END OF SCRIPT
-- =============================================
