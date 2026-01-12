CLASS lhc_zi_zbooksupp_managed_d DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS ValidateCustomerId1 FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_zbooksupp_managed_d~ValidateCustomerId1.

ENDCLASS.

CLASS lhc_zi_zbooksupp_managed_d IMPLEMENTATION.

  METHOD ValidateCustomerId1.

    READ ENTITY IN LOCAL MODE zi_zbooksupp_managed_d
    FIELDS ( TravelUuid BookingUuid BooksupplUuid SupplementID )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_travel).

    LOOP AT wtl_travel INTO DATA(wel_travel).
            reported-zi_zbooksupp_managed_d = VALUE #( BASE reported-zi_zbooksupp_managed_d (
                                                                                      %tky = wel_travel-%tky
                                                                                      %state_area = 'VALIDATE_CUSTOMER1' ) ).
        IF wel_travel-SupplementID IS INITIAL.
            failed-zi_zbooksupp_managed_d  = VALUE #(  (  %tky = wel_travel-%tky ) ).
            reported-zi_zbooksupp_managed_d = VALUE #( BASE reported-zi_zbooksupp_managed_d ( %msg = new_message_with_text(
                                                                                               severity = if_abap_behv_message=>severity-error
                                                                                               text     = 'Custom id is not present'
                                                                                             )

                                                                                      %path-zi_zbooking_managed_d-BookingUuid = wel_travel-BookingUuid
                                                                                      %path-zi_ztravel_managed_d-TravelUuid = wel_travel-TravelUuid
                                                                                      %state_area = 'VALIDATE_CUSTOMER1'
                                                                                      %element-supplementid = if_abap_behv=>mk-on ) ).
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
