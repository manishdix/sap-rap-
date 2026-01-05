@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'zi_zbooking_managed_d'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_zbooking_managed_d
  as select from /dmo/a_booking_d 
  composition[0..*]  of zi_zbooksupp_managed_d as _BookingSupplement
  association to parent zi_ztravel_managed_d as _travel
   on $projection.TravelUuid = _travel.TravelUuid
  association [1..1] to /DMO/I_Customer          as _Customer      on  $projection.CustomerID = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier           as _Carrier       on  $projection.AirlineID = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection        as _Connection    on  $projection.AirlineID    = _Connection.AirlineID
                                                                   and $projection.ConnectionID = _Connection.ConnectionID
  association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on  $projection.BookingStatus = _BookingStatus.BookingStatus
  
{
  key booking_uuid          as BookingUuid,
      booking_id            as BookingId,
      parent_uuid           as TravelUuid,
      booking_date          as BookingDate,
      customer_id           as CustomerID,
      carrier_id            as AirlineID,
      connection_id         as ConnectionID,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,

      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      //Associations
      _Travel,
      _BookingSupplement,

      _Customer,
      _Carrier,
      _Connection,
      _BookingStatus

}
