@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZC_Zbooking_Approver'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_Zbooking_Approver as projection on ZI_ZBOOKING_TECHM
{
    key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _Bookingsuppl,
    _Booking_Status,
    _Carrier,
    _Connection,
    _Customer,
    _Travel : redirected to parent ZC_ZTRAVEL_Approver
}
