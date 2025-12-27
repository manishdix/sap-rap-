CLASS lsc_zi_ztravel_tech_m DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_ztravel_tech_m IMPLEMENTATION.

  METHOD save_modified.
    DATA: wtl_travel TYPE TABLE OF zlog_travel_m.
    DATA: wtl_supplement TYPE TABLE OF zbooksup_ayush.

    LOOP AT create-zi_ztravel_tech_m INTO DATA(wel_data).
      TRY.
          APPEND VALUE #( travelId = wel_data-TravelId
                         change_id = cl_system_uuid=>create_uuid_x16_static( )
                         changing_operation = 'CREATE'
                         changed_field_name = 'Customer Id'
                         changed_value = wel_data-CustomerId
                          ) TO wtl_travel.
          APPEND VALUE #( travelId = wel_data-TravelId
                         change_id = cl_system_uuid=>create_uuid_x16_static( )
                         changing_operation = 'CREATE'
                         changed_field_name = 'Agency Id'
                         changed_value = wel_data-AgencyId
                          ) TO wtl_travel.
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.
    ENDLOOP.

    LOOP AT update-zi_ztravel_tech_m INTO DATA(wel_data1).
      TRY.
          IF wel_data1-%control-CustomerId = '01'.
            APPEND VALUE #( travelId = wel_data1-TravelId
                           change_id = cl_system_uuid=>create_uuid_x16_static( )
                           changing_operation = 'UPDATE'
                           changed_field_name = 'Customer Id'
                           changed_value = wel_data1-CustomerId
                            ) TO wtl_travel.
          ENDIF.

          IF wel_data1-%control-AgencyId = '01'.
            APPEND VALUE #( travelId = wel_data1-TravelId
                            change_id = cl_system_uuid=>create_uuid_x16_static( )
                           changing_operation = 'UPDATE'
                           changed_field_name = 'Agency Id'
                           changed_value = wel_data1-AgencyId
                            ) TO wtl_travel.
          ENDIF.
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.
    ENDLOOP.

    LOOP AT delete-zi_ztravel_tech_m INTO DATA(wel_data2).
      TRY.

          APPEND VALUE #( travelId = wel_data2-TravelId
                         change_id = cl_system_uuid=>create_uuid_x16_static( )
                         changing_operation = 'DELETE'
                         changed_field_name = 'Travel Id'
                          ) TO wtl_travel.

        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.
    ENDLOOP.

    INSERT zlog_travel_m FROM TABLE @wtl_travel.

    IF create-zi_zbooksuppl_tech_m IS NOT INITIAL.
      wtl_supplement = CORRESPONDING #( create-zi_zbooksuppl_tech_m MAPPING booking_id = BookingId booking_supplement_id = BookingSupplementId
                                                                            currency_code = CurrencyCode last_changed_at = LastChangedAt
                                                                            price = Price travel_id = TravelId supplement_id = SupplementId
                                                                            ).
      INSERT zbooksup_ayush FROM TABLE @wtl_supplement.
    ENDIF.

    IF update-zi_zbooksuppl_tech_m IS NOT INITIAL.
      wtl_supplement = CORRESPONDING #( update-zi_zbooksuppl_tech_m MAPPING booking_id = BookingId booking_supplement_id = BookingSupplementId
                                                                            currency_code = CurrencyCode last_changed_at = LastChangedAt
                                                                            price = Price travel_id = TravelId supplement_id = SupplementId
                                                                            ).
      INSERT zbooksup_ayush FROM TABLE @wtl_supplement.
    ENDIF.

    IF delete-zi_zbooksuppl_tech_m IS NOT INITIAL.
      wtl_supplement = CORRESPONDING #( delete-zi_zbooksuppl_tech_m MAPPING booking_id = BookingId
                                                                            booking_supplement_id = BookingSupplementId
                                                                            travel_id = TravelId
                                                                            ).
      DELETE zbooksup_ayush FROM TABLE @wtl_supplement.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_ztravel_tech_m RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_ztravel_tech_m RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_ztravel_tech_m.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_ztravel_tech_m\_Booking.

    METHODS copyTravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_ztravel_tech_m~copyTravel.
    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION zi_ztravel_tech_m~approve RESULT result.

    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION zi_ztravel_tech_m~reject RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_ztravel_tech_m RESULT result.
    METHODS val_customerid FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_ztravel_tech_m~val_customerid.
    METHODS calculate_total_price FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_ztravel_tech_m~calculate_total_price.
    METHODS recal_price FOR MODIFY
      IMPORTING keys FOR ACTION zi_ztravel_tech_m~recal_price.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA: lt_travel_dbs_m TYPE TABLE FOR MAPPED EARLY zi_ztravel_tech_m.
    " Get Entities
    DATA(lt_entities) = entities.
    DELETE lt_entities WHERE TravelId IS NOT INITIAL.
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #( lines( lt_entities ) )
          IMPORTING
            number            =  DATA(latest_number)
            returncode        = DATA(returncode)
            returned_quantity = DATA(rqty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).
        LOOP AT lt_entities INTO DATA(ls_entities).
          " We need to update the failed entries
          APPEND VALUE #( %cid = ls_entities-%cid
                           %key = ls_entities-%key ) TO failed-zi_ztravel_tech_m.
          " Append the Error message to reported.
          APPEND VALUE #( %cid = ls_entities-%cid
                          %key = ls_entities-%key
                          %msg = lo_error  ) TO reported-zi_ztravel_tech_m.
        ENDLOOP.
        EXIT.

    ENDTRY.
    ASSERT rqty = lines( lt_entities ).
    " Rqty will have the total values of numbers returned.
    DATA(lv_curr_num) = latest_number - rqty.
    LOOP AT lt_entities INTO ls_entities.
      lv_curr_num = lv_curr_num + 1.
      APPEND VALUE #( %cid = ls_entities-%cid
                      Travelid = lv_curr_num ) TO mapped-zi_ztravel_tech_m.

    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    DATA: max_book_num TYPE /dmo/booking_id.

    READ ENTITIES OF zi_ztravel_tech_m IN LOCAL MODE
    ENTITY zi_ztravel_tech_m BY \_booking
    FROM CORRESPONDING #( entities )
*    RESULT data(lt_result_data) " This will fetch the entire data.
    LINK DATA(lt_link_data). " This will fetch only only the relationship data (
    " ex what bookings are there for travel)


    " Assuming we get multiple travel entries.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entities>)
                              GROUP BY <ls_group_entities>-TravelId.

      " Link data - which stores all the bookings ID's for the travel, which is already created.
      max_book_num = REDUCE #( INIT lv_max  = CONV /dmo/booking_id( '0' )
                               FOR ls_link IN lt_link_data
                               WHERE ( source-TravelId = <ls_group_entities>-TravelId )
                               NEXT lv_max = COND #(  WHEN lv_max < ls_link-target-BookingId
                                                      THEN ls_link-target-BookingId
                                                      ELSE lv_max ) ).

      " Get the Max booking number, if there any
      max_book_num = REDUCE #(  INIT lv_max = max_book_num
                                FOR ls_entity IN entities USING KEY entity
                                WHERE (  TravelId = <ls_group_entities>-TravelId )
                                FOR ls_booking IN ls_entity-%target
                                NEXT lv_max = COND #(  WHEN lv_max < ls_booking-BookingId
                                                        THEN ls_booking-BookingId
                                                        ELSE lv_max ) ).


      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entites>).
        " update the Booking value
        LOOP AT <ls_entites>-%target ASSIGNING FIELD-SYMBOL(<ls_bookings>).
          APPEND CORRESPONDING #(  <ls_bookings> )  TO mapped-zi_zbooking_techm ASSIGNING FIELD-SYMBOL(<ls_new_map_booking>).
          IF <ls_bookings>-BookingId IS INITIAL.
            max_book_num = max_book_num + 10.
            <ls_new_map_booking>-BookingId = max_book_num.
          ENDIF.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD copyTravel.
    DATA: wtl_travel_C  TYPE TABLE FOR CREATE zi_ztravel_tech_m,
          wel_travel_c  LIKE LINE OF wtl_travel_C,
          wtl_booking_C TYPE TABLE FOR CREATE zi_ztravel_tech_m\_booking,
          wel_booking_C LIKE LINE OF wtl_booking_C,
          wtl_suppl_C   TYPE TABLE FOR CREATE zi_zbooking_techm\_Bookingsuppl,
          wel_suppl_C   LIKE LINE OF wtl_suppl_C.

    IF line_exists(  keys[ %cid = abap_false ] ).
      ASSERT 1 = 2.
    ENDIF.

    READ ENTITY zi_ztravel_tech_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(wtl_travel)
    FAILED DATA(wtl_failed).
    IF wtl_failed IS NOT INITIAL.
      ASSERT 1 = 2.
    ELSE.
      READ ENTITIES OF zi_ztravel_tech_m IN LOCAL MODE
      ENTITY zi_ztravel_tech_m BY \_booking
      ALL FIELDS WITH CORRESPONDING #( wtl_travel )
      RESULT DATA(wtl_booking).
      IF wtl_booking IS NOT INITIAL.

        READ ENTITIES OF zi_ztravel_tech_m IN LOCAL MODE
      ENTITY zi_zbooking_techm BY \_Bookingsuppl
      ALL FIELDS WITH CORRESPONDING #( wtl_booking )
      RESULT DATA(wtl_supplement).
      ENDIF.
    ENDIF.

    LOOP AT wtl_travel INTO DATA(wel_travel).

      IF wel_travel-TravelId IS NOT INITIAL.
        wel_travel_c-%cid  = VALUE #(  keys[ TravelId = wel_travel-TravelId ]-%cid OPTIONAL ).
        wel_travel_c-%data = CORRESPONDING #(  wel_travel EXCEPT TravelId ).
        APPEND wel_travel_c TO wtl_travel_C.

        wel_booking_C-%cid_ref = wel_travel_c-%cid.

        CLEAR wel_travel_c.

        LOOP AT wtl_booking INTO DATA(wel_booking) WHERE TravelId = wel_travel-TravelId.
          APPEND VALUE #( %cid = |{ wel_travel_c-%cid }{ wel_booking-BookingId }|  %data = CORRESPONDING #( wel_booking EXCEPT travelID BookingId  ) )
          TO wel_booking_C-%target.

          wel_suppl_C-%cid_ref = |{ wel_travel_c-%cid }{ wel_booking-BookingId }|.
          LOOP AT wtl_supplement INTO DATA(wel_supplement) WHERE TravelId = wel_travel-TravelId AND BookingId = wel_booking-BookingId.
            APPEND VALUE #( %cid = |{ wel_travel_c-%cid }{ wel_supplement-BookingId }{ wel_supplement-BookingSupplementId }|
                            %data = CORRESPONDING #( wel_supplement EXCEPT travelID BookingId BookingSupplementId ) )
         TO wel_suppl_C-%target.
          ENDLOOP.

          APPEND wel_suppl_C TO wtl_suppl_c.
          CLEAR wel_suppl_C.
        ENDLOOP.

        APPEND wel_booking_C TO wtl_booking_C.
        CLEAR wel_booking_C.

      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zi_ztravel_tech_m
    ENTITY zi_ztravel_tech_m
    CREATE FIELDS (  AgencyId CustomerId BeginDate EndDate TotalPrice )
    WITH wtl_travel_C
    ENTITY zi_ztravel_tech_m CREATE BY \_Booking
    FIELDS (  BookingDate CustomerId CarrierId FlightDate ConnectionId FlightPrice )
    WITH wtl_booking_C
    ENTITY zi_zbooking_techm CREATE BY \_Bookingsuppl
    FIELDS ( Price  )
    WITH wtl_suppl_c
    MAPPED DATA(wt_data).

    mapped = VALUE #( zi_ztravel_tech_m = wt_data-zi_ztravel_tech_m
                      zi_zbooking_techm = wt_data-zi_zbooking_techm
                      zi_zbooksuppl_tech_m = wt_data-zi_zbooksuppl_tech_m ).
  ENDMETHOD.

  METHOD approve.

    MODIFY ENTITY zi_ztravel_tech_m
  UPDATE FIELDS ( OverallStatus )
  WITH VALUE #(  FOR key IN keys ( %pky = key-%pky OverallStatus = 'A' )  ).

    READ ENTITY zi_ztravel_tech_m
   ALL FIELDS WITH CORRESPONDING #( keys )
   RESULT DATA(wtl_travel).

    IF wtl_travel IS NOT INITIAL.

      LOOP AT wtl_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

        APPEND VALUE #( %tky = <fs_travel>-%tky %param = <fs_travel> )  TO result.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD reject.

    READ ENTITY zi_ztravel_tech_m
   ALL FIELDS WITH CORRESPONDING #( keys )
   RESULT DATA(wtl_travel).

    IF wtl_travel IS NOT INITIAL.

      DATA(wel_keys)  = VALUE #( keys[ 1 ]  OPTIONAL ).
      LOOP AT wtl_travel ASSIGNING FIELD-SYMBOL(<fs_travel>) WHERE travelid = wel_keys-%pky-TravelId.
        <fs_travel>-OverallStatus = 'X'.
        APPEND VALUE #( %cid_ref = wel_keys-%cid_ref travelId  = <fs_travel>-TravelId %param = CORRESPONDING #( <fs_travel>-%data ) ) TO result.
      ENDLOOP.
      MODIFY ENTITY zi_ztravel_tech_m
      UPDATE FIELDS ( OverallStatus )
      WITH CORRESPONDING #(  wtl_travel ).

    ENDIF.



  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_ztravel_tech_m IN LOCAL MODE
    ENTITY zi_ztravel_tech_m
    FIELDS ( TravelId OverallStatus )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_travel).
    IF wtl_travel IS NOT INITIAL.
      result = VALUE #( FOR wel_travel IN wtl_travel (
                          %tky =  wel_travel-%tky
                          %features-%action-approve = COND #( WHEN wel_travel-OverallStatus = 'A'
                                                              THEN '01' )
                          %features-%action-reject = COND #( WHEN wel_travel-OverallStatus = 'X'
                                                              THEN '01'  )
                          %assoc-_Booking = COND #( WHEN wel_travel-OverallStatus = 'X'
                                                              THEN '01' )
                      ) ).
    ENDIF.
  ENDMETHOD.

  METHOD val_customerid.
    READ ENTITY IN LOCAL MODE zi_ztravel_tech_m
    FIELDS (  CustomerId )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_travel).
    IF wtl_travel IS NOT INITIAL.
      SELECT customer_Id FROM /dmo/customer
      FOR ALL ENTRIES IN @wtl_travel
      WHERE customer_Id = @wtl_travel-CustomerId
      INTO TABLE @DATA(wtl_customer) .

      LOOP AT wtl_travel INTO DATA(wel_data).
        IF wel_Data-CustomerId IS INITIAL OR NOT Line_exists( wtl_customer[  customer_id = wel_data-CustomerId ]  ).
          failed-zi_ztravel_tech_m = VALUE #( BASE failed-zi_ztravel_tech_m (  %tky =  wel_data-%tky   ) ).
          reported-zi_ztravel_tech_m = VALUE #( BASE reported-zi_ztravel_tech_m (  %tky =  wel_data-%tky
                                                                                   %msg = NEW /dmo/cm_flight_messages(
            textid                = /dmo/cm_flight_messages=>customer_unkown
            customer_id           = wel_data-CustomerId
            severity = CONV #( 'E' )
              )
                                                                                   %element-customerid = '01'
                                                                                   ) ).
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.

  METHOD calculate_total_price.
    MODIFY ENTITY IN LOCAL MODE zi_ztravel_tech_m
    EXECUTE recal_price
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD recal_price.
    READ ENTITY IN LOCAL MODE zi_ztravel_tech_m
    FIELDS ( travelID BookingFee CurrencyCode )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(wtl_travel).

    READ ENTITIES OF zi_ztravel_tech_m IN LOCAL MODE
    ENTITY zi_ztravel_tech_m BY \_Booking
      FIELDS ( FlightPrice CurrencyCode )
      WITH CORRESPONDING #(  wtl_travel )
      RESULT DATA(wtl_booking).

    READ ENTITIES OF zi_ztravel_tech_m IN LOCAL MODE
    ENTITY zi_zbooking_techm BY \_Bookingsuppl
      FIELDS ( Price CurrencyCode )
      WITH CORRESPONDING #(  wtl_booking )
      RESULT DATA(wtl_book_suppl).

    LOOP AT wtl_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      IF <fs_travel>-CurrencyCode IS NOT INITIAL.
        <fs_travel>-TotalPrice = <fs_travel>-BookingFee.
      ENDIF.

      LOOP AT wtl_booking ASSIGNING FIELD-SYMBOL(<fs_booking>).
        IF <fs_booking>-CurrencyCode IS NOT INITIAL.
          <fs_travel>-TotalPrice = <fs_travel>-TotalPrice + <fs_booking>-Flightprice.
        ENDIF.
      ENDLOOP.

      LOOP AT wtl_book_suppl ASSIGNING FIELD-SYMBOL(<fs_booking_suupl>).
        IF <fs_booking_suupl>-CurrencyCode IS NOT INITIAL.
          <fs_travel>-TotalPrice = <fs_travel>-TotalPrice + <fs_booking_suupl>-price.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zi_ztravel_tech_m
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #(  wtl_travel ).

  ENDMETHOD.

ENDCLASS.
