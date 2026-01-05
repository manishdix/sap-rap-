@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'zi_zbooking_managed_d'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_zbooksupp_managed_d
  as select from /dmo/a_bksuppl_d
  association to parent zi_zbooking_managed_d as _booking
  on $projection.BookingUuid = _booking.BookingUuid
  association[1..1] to zi_ztravel_managed_d as _travel
  on $projection.TravelUuid = _travel.TravelUuid
  association [1..1] to /DMO/I_Supplement     as _Product        on $projection.SupplementID = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on $projection.SupplementID = _SupplementText.SupplementID
{
  key booksuppl_uuid        as BooksupplUuid,
      booking_supplement_id as BookingSupplementID,
      root_uuid             as TravelUuid,
      parent_uuid               as BookingUuid,
      supplement_id         as SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as BookSupplPrice,
      currency_code         as CurrencyCode,

      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      //Associations
      _travel,
      _booking,

      _Product,
      _SupplementText
}
