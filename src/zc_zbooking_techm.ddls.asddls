@EndUserText.label: 'Booking Projetion'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_zBOOKING_TECHM
  as projection on ZI_zBOOKING_TECHM
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName         as CustomerName,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      _Carrier.Name              as CarrierName,
      ConnectionId,
      FlightDate,
      FlightPrice,
      CurrencyCode,
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      BookingStatus,
      _Booking_Status._Text.Text as BookingStatusText : localized,
      LastChangedAt, 
      /* Associations */
      _Bookingsuppl : redirected to composition child ZC_ZBOOKSUPPL_TECH_M,
      _Booking_Status,
      _Carrier,
      _Connection,
      _Customer,
      _Travel       : redirected to parent ZC_ZTRAVEL_TECH_M
}
