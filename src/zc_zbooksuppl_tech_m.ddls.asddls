@EndUserText.label: 'Booking Supp Projection View Manged'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_ZBOOKSUPPL_TECH_M
  as projection on ZI_ZBOOKSUPPL_TECH_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: [ 'SupplemenDesc' ]
      SupplementId,
      _SupplementText.Description as SupplemenDesc : localized,
      Price,
      CurrencyCode, 
      LastChangedAt,
      /* Associations */
      _Travel  : redirected to ZC_ZTRAVEL_TECH_M,
      _Booking : redirected to parent ZC_ZBOOKING_TECHM,
      _Supplement,
      _SupplementText
}
