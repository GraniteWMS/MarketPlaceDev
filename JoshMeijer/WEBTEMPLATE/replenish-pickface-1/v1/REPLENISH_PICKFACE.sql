{{#if Qty}}
    <div>
        <small>Replenish Qty</small>
        <header class="gn-float-right">{{Qty}}</header>
    </div>
{{/if}}


{{#if Location}}
    {{
        "SELECT TOP 1 Name
        FROM Location
        WHERE Barcode = @Location OR Name = @Location"
        | dbSingle({Location})
        | to => location
    }}
    <div>
        <small>Replenish Location</small>
        <header class="gn-float-right">{{location.Name}}</header>
    </div>
{{/if}}
<hr />

{{#if FromTrackingEntity}}
    {{
        "SELECT MasterItem.Code, MasterItem.Description, CarryingEntity.Barcode Pallet, 
        TrackingEntity.Barcode, Location.Name LocationName, ERPLocation, Qty, SerialNumber, Batch, ExpiryDate
        FROM TrackingEntity INNER JOIN 
        MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID INNER JOIN
        Location ON TrackingEntity.Location_id = Location.ID LEFT JOIN
        CarryingEntity ON TrackingEntity.BelongsToEntity_id = CarryingEntity.ID
        WHERE TrackingEntity.Barcode = @FromTrackingEntity"
        | dbSingle({FromTrackingEntity})
        | to => fromTrackingEntity
    }}
    <div>
        <header>{{fromTrackingEntity.Code}}</header>
    </div>
    <div>
        <small style="-ms-word-wrap: break-word; word-wrap: break-word;">{{fromTrackingEntity.Description}}</small>
    </div>

    {{#if fromTrackingEntity.Pallet}}
    <div>
        <header>Pallet</header>
        <header class="gn-float-right">{{fromTrackingEntity.Pallet}}</header>
    </div>
    {{/if}}
    <div>
        <small>Barcode</small>
        <header class="gn-float-right">{{fromTrackingEntity.Barcode}}</header>
    </div>
    <div>
        <small>Location</small>
        <header class="gn-float-right">{{fromTrackingEntity.LocationName}} <small style="font-style:normal">{{fromTrackingEntity.ERPLocation}}</small></header>
    </div>
    <div>
        <small>Qty</small>
        <header class="gn-float-right">{{fromTrackingEntity.Qty}}</header>
    </div>
    <hr />

    {{#if fromTrackingEntity.SerialNumber}}
    <div>
        <small>Serial</small>
        <header class="gn-float-right">{{fromTrackingEntity.SerialNumber}}</header>
    </div>
    {{/if}}

    {{#if fromTrackingEntity.Batch}}
    <div>
        <small>Batch</small>
        <header class="gn-float-right">{{fromTrackingEntity.Batch}}</header>
    </div>
    {{/if}}

    {{#if fromTrackingEntity.ExpiryDate}}
    <div>
        <small>Expiry</small>
        <header class="gn-float-right">{{fromTrackingEntity.ExpiryDate}}</header>
    </div>
    {{/if}}
{{/if}}