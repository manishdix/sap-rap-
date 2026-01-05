@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZC_ZBOOKSUPP_MANAGED_D'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_ZBOOKSUPP_MANAGED_D as projection on zi_zbooksupp_managed_d
{
    key BooksupplUuid,
    BookingSupplementID,
    TravelUuid,
    BookingUuid,
    SupplementID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookSupplPrice,
    CurrencyCode,
    LocalLastChangedAt,
    /* Associations */
    _booking : redirected to parent ZC_ZBOOKING_MANAGED_D,
    _Product,
    _SupplementText,
    _travel : redirected to ZC_ZTRAVEL_MANAGED_D
}
