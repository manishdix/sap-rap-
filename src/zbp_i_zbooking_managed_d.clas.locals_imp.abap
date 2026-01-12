CLASS lhc_zi_zbooking_managed_d DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_zbooking_managed_d~calculateTotalPrice.

    METHODS setBookingDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_zbooking_managed_d~setBookingDate.

    METHODS setBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_zbooking_managed_d~setBookingId.
    METHODS ValidateCustomerId FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_zbooking_managed_d~ValidateCustomerId.

ENDCLASS.

CLASS lhc_zi_zbooking_managed_d IMPLEMENTATION.

  METHOD calculateTotalPrice.
    READ ENTITY IN LOCAL MODE zi_zbooking_managed_d
        BY \_Travel
        FIELDS ( TravelUuid TravelId )
        WITH CORRESPONDING #(  keys )
        RESULT DATA(wtl_travel).

    MODIFY ENTITY IN LOCAL MODE zi_ztravel_managed_d
    EXECUTE recalculatePrice FROM CORRESPONDING #( wtl_travel  ).

  ENDMETHOD.

  METHOD setBookingDate.
    READ ENTITY IN LOCAL MODE zi_zbooking_managed_d
        BY \_Travel
        FIELDS ( TravelUuid TravelId )
        WITH CORRESPONDING #(  keys )
        RESULT DATA(wtl_travel).

    DATA: wtl_book TYPE TABLE FOR UPDATE zi_zbooking_managed_d.
    DATA: lv_cal TYPE i.

    LOOP AT wtl_travel INTO DATA(wel_travel).
      READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
     BY \_booking
     FIELDS ( BookingUuid BookingDate )
     WITH VALUE #( ( %tky = wel_travel-%tky )  )
     RESULT DATA(wtl_Booking).


      LOOP AT wtl_booking INTO DATA(wel_booking) WHERE BookingDate IS INITIAL.
        wel_booking-BookingDate = cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #( %tky = wel_booking-%tky BookingDate = wel_booking-BookingDate  ) TO wtl_book.
      ENDLOOP.

    ENDLOOP.



    CHECK wtl_travel IS NOT INITIAL.

    MODIFY ENTITY IN LOCAL MODE zi_zbooking_managed_d UPDATE
    FIELDS (  BookingDate ) WITH wtl_book.

  ENDMETHOD.

  METHOD setBookingId.
    READ ENTITY IN LOCAL MODE zi_zbooking_managed_d
      BY \_Travel
      FIELDS ( TravelUuid TravelId )
      WITH CORRESPONDING #(  keys )
      RESULT DATA(wtl_travel).


    DATA: wtl_book TYPE TABLE FOR UPDATE zi_zbooking_managed_d.
    DATA: lv_cal TYPE i.

    LOOP AT wtl_travel INTO DATA(wel_travel).
      READ ENTITY IN LOCAL MODE zi_ztravel_managed_d
     BY \_booking
     FIELDS ( BookingUuid BookingId )
     WITH VALUE #( ( %tky = wel_travel-%tky )  )
     RESULT DATA(wtl_Booking).


      LOOP AT wtl_booking INTO DATA(wel_booking).
        lv_cal = COND #( WHEN wel_booking-BookingId > lv_cal THEN wel_booking-BookingId ELSE lv_cal ).
      ENDLOOP.

      LOOP AT wtl_booking INTO wel_booking WHERE BookingId = abap_false.
        lv_cal = lv_cal + 1.
        APPEND VALUE #( %tky = wel_booking-%tky bookingId = lv_cal  ) TO wtl_book.
      ENDLOOP.

    ENDLOOP.



    CHECK wtl_travel IS NOT INITIAL.

    MODIFY ENTITY IN LOCAL MODE zi_zbooking_managed_d UPDATE
    FIELDS (  BookingId ) WITH wtl_book.
  ENDMETHOD.

  METHOD ValidateCustomerId.

    READ ENTITY IN LOCAL MODE zi_zbooking_managed_d
    FIELDS ( TravelUuid BookingUuid CustomerId )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_travel).

    LOOP AT wtl_travel INTO DATA(wel_travel).
            reported-zi_ztravel_managed_d = VALUE #( BASE reported-zi_ztravel_managed_d (
                                                                                      %tky = wel_travel-%tky
                                                                                      %state_area = 'VALIDATE_CUSTOMER1') ).
        IF wel_travel-CustomerId IS INITIAL.
            failed-zi_ztravel_managed_d  = VALUE #(  (  %tky = wel_travel-%tky ) ).
            reported-zi_zbooking_managed_d = VALUE #( BASE reported-zi_zbooking_managed_d ( %msg = new_message_with_text(
                                                                                               severity = if_abap_behv_message=>severity-error
                                                                                               text     = 'Custom id is not present'
                                                                                             )
                                                                                      %tky = wel_travel-%tky
                                                                                      %state_area = 'VALIDATE_CUSTOMER1'
                                                                                      %element-customerid = if_abap_behv=>mk-on
                                                                                       %path = VALUE #( zi_ztravel_managed_d = VALUE #(  TravelUuid = wel_travel-TravelUuid ) ) ) ).
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
