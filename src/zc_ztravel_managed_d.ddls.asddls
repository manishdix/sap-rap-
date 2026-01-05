@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZI_ZTRAVEL_MANAGED_D'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define  root   view  entity  ZC_ZTRAVEL_MANAGED_D  provider contract transactional_query as projection on zi_ztravel_managed_d 
{
    key TravelUuid,
    TravelId,
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
    OverallStatus,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Agency,
    _booking : redirected to composition child ZC_ZBOOKING_MANAGED_D,
    _Currency,
    _Customer,
    _OverallStatus
}
