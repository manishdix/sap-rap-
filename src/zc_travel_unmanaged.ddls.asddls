@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZC_TRAVEL_unmanaged'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_unmanaged
  provider contract transactional_query as projection on ZI_ZTRAVEL_UNMANAGED
{
    key TravelId,
    AgencyId,
    CustomerId,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    CurrencyCode,
    Description,
    overallstatus,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    /* Associations */
    _Agency,
    _Booking : redirected to composition child ZC_ZBOOKING_UNMANAGED,
    _Currency,
    _Customer,
    _Status
}
