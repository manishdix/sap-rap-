CLASS lhc_zi_ztravel_managed_d DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_ztravel_managed_d RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_ztravel_managed_d RESULT result.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE zi_ztravel_managed_d.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE zi_ztravel_managed_d.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_ztravel_managed_d~accepttravel RESULT result.

    METHODS discountadded FOR MODIFY
      IMPORTING keys FOR ACTION zi_ztravel_managed_d~discountadded RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_ztravel_managed_d~rejecttravel RESULT result.
    METHODS calculateprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_ztravel_managed_d~calculateprice.

    METHODS setoverallstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_ztravel_managed_d~setoverallstatus.

    METHODS settravelid FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_ztravel_managed_d~settravelid.
    METHODS getdefaultsforcreate FOR READ
      IMPORTING keys FOR FUNCTION zi_ztravel_managed_d~getdefaultsforcreate RESULT result.
    METHODS recalculateprice FOR MODIFY
      IMPORTING keys FOR ACTION zi_ztravel_managed_d~recalculateprice.
    METHODS validatecustomerid FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_ztravel_managed_d~validatecustomerid.

ENDCLASS.

CLASS lhc_zi_ztravel_managed_d IMPLEMENTATION.

  METHOD get_instance_authorizations.

*    READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
*    FIELDS ( travelId AgencyId ) WITH CORRESPONDING #( keys )
*    RESULT DATA(wtl_travel).
*
*    LOOP AT wtl_travel INTO DATA(wel_travel).
*      IF  requested_authorizations-%update = if_abap_behv=>mk-on.
*        AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*            ID '/DMO/CNTRY'  DUMMY
*            ID 'ACTVT'  FIELD '01'.
*
*        APPEND VALUE #(   %tky = wel_travel-%tky
*                          %op-%update = if_abap_behv=>op-m-update
*                          %update = COND #( WHEN wel_travel-TravelId = 2339 THEN if_abap_behv=>auth-unauthorized
*                                            ELSE if_abap_behv=>auth-allowed )
*                          TravelUuid = wel_travel-TravelUuid  )  TO result.
*      ELSEIF  requested_authorizations-%delete = if_abap_behv=>mk-on.
*        AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*            ID '/DMO/CNTRY'  DUMMY
*            ID 'ACTVT'  FIELD '01'.
*
*        APPEND VALUE #(   %tky = wel_travel-%tky
*                          %op-%delete = if_abap_behv=>op-m-delete
*                          %delete = COND #( WHEN wel_travel-TravelId = 2339 THEN if_abap_behv=>auth-unauthorized
*                                            ELSE if_abap_behv=>auth-allowed )
*                          TravelUuid = wel_travel-TravelUuid  )  TO result.
*
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.
*
  METHOD get_global_authorizations.
*    IF requested_authorizations-%create = if_abap_behv=>mk-on.
*      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*      ID '/DMO/CNTRY'  DUMMY
*      ID 'ACTVT'  FIELD '01'.
*
*      result-%create =  if_abap_behv=>auth-unauthorized.
*    ELSEIF  requested_authorizations-%update = if_abap_behv=>mk-on.
*      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*          ID '/DMO/CNTRY'  DUMMY
*          ID 'ACTVT'  FIELD '01'.
*
*      result-%update =  if_abap_behv=>auth-unauthorized.
*
*    ELSEIF  requested_authorizations-%delete = if_abap_behv=>mk-on.
*      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*          ID '/DMO/CNTRY'  DUMMY
*          ID 'ACTVT'  FIELD '01'.
*
*      result-%delete =  if_abap_behv=>auth-unauthorized.
*
*    ENDIF.
  ENDMETHOD.

  METHOD precheck_create.

  ENDMETHOD.

  METHOD precheck_update.

    LOOP AT entities INTO DATA(wel_entities).
      IF wel_entities-AgencyId = '11'.
        failed-zi_ztravel_managed_d = VALUE #( BASE failed-zi_ztravel_managed_d  (  %tky  = wel_entities-%tky  ) ).
        reported-zi_ztravel_managed_d = VALUE #( BASE reported-zi_ztravel_managed_d  (  %tky  = wel_entities-%tky
                                                                                        %element-agencyid = wel_entities-AgencyId
                                                                                        %msg = new_message(
                                                                                                 id       = '/DMO/CM_FLIGHT_LEGAC'
                                                                                                 number   = '053'
                                                                                                 severity = CONV #( 'E' )
                                                                                                 v1       = wel_entities-AgencyId
*                                                                                                     v2       =
*                                                                                                     v3       =
*                                                                                                     v4       =
                                                                                               ) ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITY IN LOCAL MODE zi_ztravel_managed_d  UPDATE
    FIELDS (  OverallStatus ) WITH VALUE #( FOR key IN keys (
    %tky = key-%tky
    OverallStatus = 'A'
     ) ).

    READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
    ALL FIELDS WITH
    CORRESPONDING #(  keys )
    RESULT DATA(wtl_result).

    LOOP AT wtl_result INTO DATA(wel_data).

      result = VALUE #( BASE result  ( %tky = wel_data-%tky %param = CORRESPONDING #( wel_data ) ) ).
    ENDLOOP.


  ENDMETHOD.

  METHOD discountadded.
    DATA(wtl_keys) = keys.

    DATA: wtl_modify TYPE TABLE FOR UPDATE zi_ztravel_managed_d.
    LOOP AT wtl_keys INTO DATA(wel_keys).
      IF wel_keys-%param-discount IS INITIAL OR wel_keys-%param-discount < 0 OR wel_keys-%param-discount > 100.
        APPEND VALUE #(   %tky = wel_keys-%tky %cid = wel_keys-%cid_ref  ) TO failed-zi_ztravel_managed_d.
        reported-zi_ztravel_managed_d = VALUE #( BASE reported-zi_ztravel_managed_d ( %cid = wel_keys-%cid_ref %tky = wel_keys-%tky
                                                                                      %msg = new_message_with_text(
                                                                                               severity = if_abap_behv_message=>severity-error
                                                                                               text     = 'Wrong discount entered'
                                                                                             ) ) ).
        DELETE wtl_keys INDEX sy-tabix.
      ENDIF.

    ENDLOOP.

    CHECK wtl_keys IS NOT INITIAL.

    READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
    FIELDS (  TravelUUId BookingFee )
    WITH CORRESPONDING #(  wtl_keys )
    RESULT DATA(wtl_result).

    LOOP AT wtl_result INTO DATA(wel_result).
      READ TABLE wtl_keys INTO wel_keys WITH KEY %tky = wel_result-%tky.
      IF sy-subrc = 0.
        DATA(wl_total) = wel_result-BookingFee  - (   wel_result-BookingFee * ( wel_keys-%param-discount / 100  ) ) .
      ENDIF.

      wtl_modify = VALUE #(  BASE wtl_modify ( %tky = wel_result-%tky BookingFee = wl_total  ) ).
    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zi_ztravel_managed_d  UPDATE
    FIELDS (  BookingFee ) WITH wtl_modify.

    READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
    ALL FIELDS WITH
    CORRESPONDING #(  wtl_keys )
    RESULT wtl_result.

    LOOP AT wtl_result INTO DATA(wel_data).

      result = VALUE #( BASE result  ( %tky = wel_data-%tky %param = CORRESPONDING #( wel_data ) ) ).
    ENDLOOP.

  ENDMETHOD.



  METHOD rejectTravel.
    DATA: wtl_update TYPE TABLE FOR UPDATE zi_ztravel_managed_d.

    wtl_update = CORRESPONDING #( keys ).
    LOOP AT wtl_update ASSIGNING FIELD-SYMBOL(<fs_data>).
      <fs_data>-OverallStatus = 'R'.
    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zi_ztravel_managed_d  UPDATE
    FIELDS (  OverallStatus ) WITH wtl_update.

    READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
    ALL FIELDS WITH
    CORRESPONDING #(  keys )
    RESULT DATA(wtl_result).

    LOOP AT wtl_result INTO DATA(wel_data).

      result = VALUE #( BASE result  ( %tky = wel_data-%tky %param = CORRESPONDING #( wel_data ) ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD calculatePrice.
     MODIFY ENTITY IN LOCAL MODE zi_ztravel_managed_d
    EXECUTE recalculatePrice FROM CORRESPONDING #(  keys ).
  ENDMETHOD.

  METHOD setOverallStatus.


    READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
    FIELDS ( TravelUuid OverallStatus )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_travel).

    DELETE wtl_travel WHERE overallstatus IS NOT INITIAL.

    CHECK wtl_travel IS NOT INITIAL.

    MODIFY ENTITY IN LOCAL MODE zi_ztravel_managed_d  UPDATE
    FIELDS (  OverallStatus ) WITH VALUE #(  FOR wel_travel IN wtl_travel
                                        (
                                           %tky = wel_travel-%tky
                                           OverallStatus = 'O'

                                        ) ).

  ENDMETHOD.

  METHOD setTravelId.
    READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
    FIELDS ( TravelUuid TravelId )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_travel).

    DELETE wtl_travel WHERE travelId IS NOT INITIAL.

    CHECK wtl_travel IS NOT INITIAL.

    SELECT MAX( travel_Id )
    FROM /dmo/a_travel_d INTO
    @DATA(wl_max).

    MODIFY ENTITY IN LOCAL MODE zi_ztravel_managed_d  UPDATE
    FIELDS (  TravelId ) WITH VALUE #(  FOR wel_travel IN wtl_travel INDEX INTO wl_index
                                        (
                                           %tky = wel_travel-%tky
                                           TravelId = wl_max + wl_index

                                        ) ).

  ENDMETHOD.

  METHOD GetDefaultsForCreate.
  ENDMETHOD.

  METHOD recalculatePrice.
     READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
    FIELDS ( TravelUuid BookingFee )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_travel).


    READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
    BY \_booking
    FIELDS ( TravelUuid BookingUuid FlightPrice )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_booking).


    READ ENTITY IN LOCAL MODE zi_zbooking_managed_d
    BY \_BookingSupplement
    FIELDS ( TravelUuid BookingUuid BooksupplUuid BookSupplPrice )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_booksupp).

    LOOP AT wtl_travel INTO DATA(wel_travel).

      wel_travel-TotalPrice = wel_travel-BookingFee.
      LOOP AT wtl_booking INTO DATA(wel_booking) WHERE TravelUuid = wel_travel-TravelUuid .
        wel_travel-TotalPrice = wel_booking-FlightPrice +  wel_travel-TotalPrice.
      ENDLOOP.

      LOOP AT wtl_booksupp INTO DATA(wel_supp) WHERE TravelUuid = wel_travel-TravelUuid .
        wel_travel-TotalPrice = wel_supp-BookSupplPrice +  wel_travel-TotalPrice.
      ENDLOOP.

      MODIFY wtl_travel FROM wel_travel.
    ENDLOOP.

    MODIFY ENTITY  IN LOCAL MODE  zi_ztravel_managed_d  UPDATE
    FIELDS (  TotalPrice ) WITH CORRESPONDING #(  wtl_travel ).

  ENDMETHOD.

  METHOD ValidateCustomerId.

    READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
    FIELDS ( TravelUuid TravelId CustomerId )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_travel).

    LOOP AT wtl_travel INTO DATA(wel_travel).
            reported-zi_ztravel_managed_d = VALUE #( BASE reported-zi_ztravel_managed_d (
                                                                                      %tky = wel_travel-%tky
                                                                                      %state_area = 'VALIDATE_CUSTOMER') ).
        IF wel_travel-CustomerId IS INITIAL.
            failed-zi_ztravel_managed_d  = VALUE #(  (  %tky = wel_travel-%tky ) ).
            reported-zi_ztravel_managed_d = VALUE #( BASE reported-zi_ztravel_managed_d ( %msg = new_message_with_text(
                                                                                               severity = if_abap_behv_message=>severity-error
                                                                                               text     = 'Custom id is not present'
                                                                                             )
                                                                                      %tky = wel_travel-%tky
                                                                                      %state_area = 'VALIDATE_CUSTOMER'
                                                                                      %element-customerid = if_abap_behv=>mk-on ) ).
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
