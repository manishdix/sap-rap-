CLASS lhc_ZI_ZBOOKING_TECHM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zi_zbooking_techm\_Bookingsuppl.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZI_ZBOOKING_TECHM RESULT result.
    METHODS calculate_total_price FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_zbooking_techm~calculate_total_price.

ENDCLASS.

CLASS lhc_ZI_ZBOOKING_TECHM IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.
    DATA: max_book_num TYPE /dmo/booking_id.

    READ ENTITIES OF zi_ztravel_tech_m IN LOCAL MODE
    ENTITY zi_zbooking_techm BY \_Bookingsuppl
    FROM CORRESPONDING #( entities )
*    RESULT data(lt_result_data) " This will fetch the entire data.
    LINK DATA(lt_link_data). " This will fetch only only the relationship data (
    " ex what bookings are there for travel)


    " Assuming we get multiple travel entries.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entities>)
                              GROUP BY ( travelId = <ls_group_entities>-TravelId
                                        BookingId = <ls_group_entities>-BookingId ).

      " Link data - which stores all the bookings ID's for the travel, which is already created.
      max_book_num = REDUCE #( INIT lv_max  = CONV /dmo/booking_id( '0' )
                               FOR ls_link IN lt_link_data
                               WHERE ( source-TravelId = <ls_group_entities>-TravelId  AND
                                       source-BookingId = <ls_group_entities>-BookingId  )
                               NEXT lv_max = COND #(  WHEN lv_max < ls_link-target-BookingSupplementId
                                                      THEN ls_link-target-BookingSupplementId
                                                      ELSE lv_max ) ).

      " Get the Max booking number, if there any
      max_book_num = REDUCE #(  INIT lv_max = max_book_num
                                FOR ls_entity IN entities USING KEY entity
                                WHERE (  TravelId = <ls_group_entities>-TravelId AND
                                         BookingId = <ls_group_entities>-BookingId )
                                FOR ls_booking IN ls_entity-%target
                                NEXT lv_max = COND #(  WHEN lv_max < ls_booking-BookingSupplementId
                                                        THEN ls_booking-BookingSupplementId
                                                        ELSE lv_max ) ).


      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entites>).
        " update the Booking value
        LOOP AT <ls_entites>-%target ASSIGNING FIELD-SYMBOL(<ls_bookings>).
          APPEND CORRESPONDING #(  <ls_bookings> )  TO mapped-zi_zbooksuppl_tech_m ASSIGNING FIELD-SYMBOL(<ls_new_map_booking>).
          IF <ls_bookings>-BookingSupplementId IS INITIAL.
            max_book_num = max_book_num + 10.
            <ls_new_map_booking>-BookingSupplementId = max_book_num.
          ENDIF.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
  READ ENTITIES OF zi_ztravel_tech_m IN LOCAL MODE
    ENTITY zi_ztravel_tech_m BY \_Booking
    FIELDS ( TravelId BookingId BookingStatus )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_booking).
    IF wtl_booking IS NOT INITIAL.
        result = VALUE #( for wel_travel IN wtl_booking (
                            %tky =  wel_travel-%tky
                            travelId = wel_travel-TravelId
                            bookingId = wel_travel-bookingId
                            %assoc-_Bookingsuppl = COND #( WHEN wel_travel-BookingStatus = 'X'
                                                                THEN '01' )
                        ) ).
   ENDIF.
  ENDMETHOD.

  METHOD calculate_total_price.
    MODIFY ENTITY IN LOCAL MODE zi_ztravel_tech_m
    EXECUTE recal_price
    FROM CORRESPONDING #( keys ).
  ENDMETHOD.

ENDCLASS.
