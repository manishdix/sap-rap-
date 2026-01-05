@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZI_ZBOOKING_MANAGED_D'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_ZBOOKING_MANAGED_D as projection on zi_zbooking_managed_d
{
    key BookingUuid,
    BookingId,
    TravelUuid,
    BookingDate,
    CustomerID,
    AirlineID,
    ConnectionID,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LocalLastChangedAt,
    /* Associations */
    _BookingStatus,
    _BookingSupplement: redirected to composition child ZC_ZBOOKSUPP_MANAGED_D,
    _Carrier,
    _Customer,
    _Travel : redirected to parent ZC_ZTRAVEL_MANAGED_D
}
