CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK travel.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ travel\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE travel\_Booking.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.

    TYPES: tt_failed   TYPE TABLE FOR FAILED EARLY zi_ztravel_unmanaged\\travel,
           tt_reported TYPE TABLE FOR REPORTED EARLY zi_ztravel_unmanaged\\travel.

    TYPES: tt_failed1   TYPE TABLE FOR FAILED EARLY zi_ztravel_unmanaged\\travel,
           tt_reported1 TYPE TABLE FOR REPORTED EARLY zi_ztravel_unmanaged\\travel.

    METHODS meth_travel
      IMPORTING
        iv_cid      TYPE abp_behv_cid OPTIONAL
        it_messages TYPE /dmo/t_message
        iv_travel   TYPE /dmo/travel_id OPTIONAL
      EXPORTING
        et_fail_msg TYPE tt_failed
        et_report   TYPE tt_reported
        ev_fail     TYPE abap_boolean.
    METHODS meth_travel_booking
      IMPORTING
        VALUE(iv_cid)      TYPE abp_behv_cid OPTIONAL
        VALUE(iv_travel)   TYPE /dmo/travel_id
        VALUE(it_messages) TYPE /dmo/t_message
        iv_dependency      TYPE abap_boolean OPTIONAL
      EXPORTING
        VALUE(et_fail_msg) TYPE tt_failed1
        et_report          TYPE tt_reported1
        VALUE(ev_fail)     TYPE abap_boolean.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.

    DATA: wel_travel     TYPE /dmo/s_travel_in,
          wel_travel_out TYPE /dmo/travel,
          wtl_messages   TYPE /dmo/t_message,
          wtl_failed     TYPE TABLE FOR FAILED zi_ztravel_unmanaged,
          wtl_report     TYPE TABLE FOR REPORTED zi_ztravel_unmanaged,
          wl_fail        TYPE abap_boolean,
          wel_entities   TYPE STRUCTURE FOR CREATE zi_ztravel_unmanaged.

    LOOP AT entities INTO wel_entities.
      wel_travel = CORRESPONDING #( wel_entities MAPPING FROM ENTITY USING CONTROL ).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel         = wel_travel
          iv_numbering_mode = 'L'
        IMPORTING
          es_travel         = wel_travel_out
          et_messages       = wtl_messages.

      CALL METHOD meth_travel
        EXPORTING
          iv_cid      = wel_entities-%cid
          it_messages = wtl_messages
        IMPORTING
          et_fail_msg = wtl_failed
          et_report   = wtl_report
          ev_fail     = wl_fail.

      IF wl_fail = abap_false.
        APPEND VALUE #( %cid = wel_entities-%cid
                        TravelId = wel_travel_out-travel_id ) TO mapped-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.
    DATA: wel_travel     TYPE /dmo/s_travel_in,
          wel_travel_out TYPE /dmo/travel,
          wtl_messages   TYPE /dmo/t_message,
          wtl_failed     TYPE TABLE FOR FAILED zi_ztravel_unmanaged,
          wtl_report     TYPE TABLE FOR REPORTED zi_ztravel_unmanaged,
          wl_fail        TYPE abap_boolean,
          wel_entities   TYPE STRUCTURE FOR CREATE zi_ztravel_unmanaged.
    DATA: wel_travelx TYPE /dmo/s_travel_intx.
    DATA: wel_travelx_orig TYPE /dmo/s_travel_inx.

    LOOP AT entities INTO DATA(wel_entities1).
      wel_travel = CORRESPONDING #( wel_entities1 MAPPING FROM ENTITY ).

      wel_travelx = CORRESPONDING #( wel_entities1 MAPPING FROM ENTITY USING CONTROL ).
      wel_travelx_orig = CORRESPONDING #(  wel_travelx ).
      wel_travelx_orig-travel_id = wel_entities1-TravelId.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = wel_travel
          is_travelx  = wel_travelx_orig
        IMPORTING
          es_travel   = wel_travel_out
          et_messages = wtl_messages.

      CALL METHOD meth_travel
        EXPORTING
          iv_cid      = wel_entities-%cid
          iv_travel   = wel_entities-TravelId
          it_messages = wtl_messages
        IMPORTING
          et_fail_msg = failed-travel
          et_report   = reported-travel
          ev_fail     = wl_fail.

      IF wl_fail = abap_false.
        APPEND VALUE #( %cid = wel_entities-%cid
                        TravelId = wel_travel_out-travel_id ) TO mapped-travel.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA: wel_travel     TYPE /dmo/s_travel_in,
          wel_travel_out TYPE /dmo/travel,
          wtl_messages   TYPE /dmo/t_message,
          wtl_failed     TYPE TABLE FOR FAILED zi_ztravel_unmanaged,
          wtl_report     TYPE TABLE FOR REPORTED zi_ztravel_unmanaged,
          wl_fail        TYPE abap_boolean,
          wel_entities   TYPE STRUCTURE FOR CREATE zi_ztravel_unmanaged.
    DATA: wel_travelx TYPE /dmo/s_travel_intx.
    DATA: wel_travelx_orig TYPE /dmo/s_travel_inx.

    LOOP AT keys INTO DATA(wel_entities1).
      wel_travel = CORRESPONDING #( wel_entities1 MAPPING FROM ENTITY ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = wel_travel-travel_id
        IMPORTING
          et_messages  = wtl_messages.

      CALL METHOD meth_travel
        EXPORTING
          iv_travel   = wel_entities1-TravelId
          it_messages = wtl_messages
        IMPORTING
          et_fail_msg = failed-travel
          et_report   = reported-travel
          ev_fail     = wl_fail.

      IF wl_fail = abap_false.
        APPEND VALUE #( %cid = wel_entities-%cid
                        TravelId = wel_travel_out-travel_id ) TO mapped-travel.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD read.

    DATA: wtl_messages TYPE /dmo/t_message.
    LOOP AT keys INTO DATA(wel_keys).
      DATA: wel_travel             TYPE /dmo/travel,
            wel_booking            TYPE /dmo/t_booking,
            wtl_booking_supplement TYPE /dmo/t_booking_supplement,
            wl_fail                TYPE abap_boolean.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id          = wel_keys-TravelId
*         iv_include_buffer     = abap_true
        IMPORTING
          es_travel             = wel_travel
          et_booking            = wel_booking
          et_booking_supplement = wtl_booking_supplement
          et_messages           = wtl_messages.

      me->meth_travel(
        EXPORTING
          it_messages = wtl_messages
          iv_travel   = wel_keys-TravelId
        IMPORTING
          et_fail_msg = failed-travel
          et_report   = reported-travel
          ev_fail     = wl_fail
      ).

      APPEND CORRESPONDING #( wel_travel MAPPING
        AgencyId = agency_id
   BeginDate = begin_date
   EndDate = end_date
   BookingFee = booking_fee
   CustomerId = customer_id
   Description = description
   TotalPrice = total_price
   TravelId = travel_id
   CurrencyCode = currency_code
   overallstatus  = status
    ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    DATA: wtl_messages TYPE /dmo/t_message.
    DATA: wol_lock_object TYPE REF TO if_abap_lock_object.

    TRY.
        cl_abap_lock_object_factory=>get_instance(
          EXPORTING
            iv_name        = '/DMO/ETRAVEL'
          RECEIVING
            ro_lock_object = wol_lock_object
        ).

      CATCH cx_abap_lock_failure.

    ENDTRY.

    LOOP AT keys INTO DATA(wel_keys).
      TRY.
          wol_lock_object->enqueue(
          it_table_mode = VALUE #(  (  mode = 'E'  ) )
          it_parameter  = VALUE #(  (  name = 'TRAVEL_ID' value = REF #( wel_keys-TravelId )  )
           ) ).
        CATCH cx_abap_foreign_lock cx_abap_lock_failure.

          wtl_messages = VALUE #( ( msgid = '/DMO/CM_FLIGHT_LEGAC' msgno = '032' msgty = 'E' msgv1 = wel_keys-TravelId msgv2 = sy-uname ) ).
          me->meth_travel(
            EXPORTING
              it_messages = wtl_messages
              iv_travel   = wel_keys-TravelId
            IMPORTING
              et_fail_msg = failed-travel
              et_report   = reported-travel
          ).
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Booking.
    DATA: wel_travel   TYPE /dmo/travel,
          wtl_booking  TYPE /dmo/t_booking,
          wtl_messages TYPE /dmo/t_message,
          wl_fail      TYPE abap_boolean.

    LOOP AT keys_rba INTO DATA(wel_data).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = wel_data-TravelId
        IMPORTING
          es_travel    = wel_travel
          et_booking   = wtl_booking
          et_messages  = wtl_messages.

      CALL METHOD meth_travel_booking
        EXPORTING
          iv_travel     = wel_data-TravelId
          it_messages   = wtl_messages
          iv_dependency = abap_true
        IMPORTING
          et_fail_msg   = failed-travel
          et_report     = reported-travel
          ev_fail       = wl_fail.
      IF wl_fail = abap_false.

        LOOP AT wtl_booking INTO DATA(wel_book).
          association_links = VALUE #( (  source-%tky = wel_data-%tky target-TravelId = wel_book-travel_id target-BookingId = wel_book-booking_id ) ).
        ENDLOOP.

        IF result_requested = abap_true.
          result = CORRESPONDING #( wtl_booking MAPPING
            BookingId    = booking_id
            TravelId     = travel_id
            CarrierId    = carrier_id
            ConnectionId = connection_id
            CurrencyCode = currency_code
            CustomerId   = customer_id
            FlightDate   = flight_date
            FlightPrice  = flight_price
            BookingDate  = booking_date
           ).
        ENDIF.
      ENDIF.



    ENDLOOP.


  ENDMETHOD.

  METHOD cba_Booking.

    DATA: wel_travel      TYPE /dmo/s_travel_in,
          wel_travel_out  TYPE /dmo/travel,
          wtl_messages    TYPE /dmo/t_message,
          wtl_failed      TYPE TABLE FOR FAILED zi_ztravel_unmanaged,
          wtl_report      TYPE TABLE FOR REPORTED zi_ztravel_unmanaged,
          wl_fail         TYPE abap_boolean,
          wel_entities    TYPE STRUCTURE FOR CREATE zi_ztravel_unmanaged\_Booking,
          wtl_booking     TYPE /dmo/t_booking_in,
          wel_booking     TYPE /dmo/s_booking_in,
          wtl_booking_out TYPE /dmo/t_booking,
          wtl_bookingx    TYPE /dmo/t_booking_inx,
          wel_bookingx    TYPE /dmo/s_booking_inx,
          wel_travelx     TYPE /dmo/s_travel_inx,
          wl_id           TYPE i.

    READ ENTITY IN LOCAL MODE zi_ztravel_unmanaged
    BY \_Booking
    FIELDS (  TravelId BookingId )
    WITH CORRESPONDING #(  entities_cba  )
    RESULT DATA(wt_data).

    LOOP AT entities_cba INTO wel_entities.

      DATA(wtl_copy) = wt_data.
      DELETE wtl_copy WHERE travelId <> wel_entities-TravelId.

      wl_id = lines(  wtl_copy ).

      LOOP AT wel_entities-%target INTO DATA(wel_target).
        wl_id = wl_id  + 1.
        wel_booking-travel_id = wel_entities-TravelId.
        wel_booking = CORRESPONDING #( wel_target MAPPING FROM ENTITY USING CONTROL  ).
        wel_bookingx-_intx = CORRESPONDING #( wel_target MAPPING FROM ENTITY USING CONTROL  ).
        wel_bookingx-booking_id = wl_id.
        wel_bookingx-action_code = if_abap_behv=>op-m-create.
        wel_booking-booking_id = wl_id.
        APPEND wel_booking TO wtl_booking.
        APPEND wel_bookingx TO wtl_bookingx.
      ENDLOOP.

      wel_travel-travel_id =  wel_entities-TravelId.
      wel_travelx-travel_id =  wel_entities-TravelId.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = wel_travel
          is_travelx  = wel_travelx
          it_booking  = wtl_booking
          it_bookingx = wtl_bookingx
        IMPORTING
          es_travel   = wel_travel_out
          et_booking  = wtl_booking_out
          et_messages = wtl_messages.

      CALL METHOD meth_travel_booking
        EXPORTING
          iv_cid        = wel_entities-%cid_ref
          iv_travel     = wel_entities-%key-TravelId
          it_messages   = wtl_messages
          iv_dependency = abap_true
        IMPORTING
          et_fail_msg   = failed-travel
          et_report     = reported-travel
          ev_fail       = wl_fail.

      IF wl_fail = abap_false.
        APPEND VALUE #( %cid = wel_entities-%cid_ref
                        TravelId = wel_travel_out-travel_id
                         ) TO mapped-travel.

        LOOP AT wtl_booking INTO DATA(wel_book).
          APPEND VALUE #( %cid = wel_entities-%cid_ref
                           TravelId = wel_travel_out-travel_id
                           bookingId = wel_book-booking_id ) TO mapped-booking.

        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD meth_travel.
    DATA: wel_cause TYPE if_abap_behv=>t_fail_cause.

    LOOP AT it_messages INTO DATA(wel_message).

      IF wel_message-msgty = 'E' OR wel_message-msgty = 'A'.
        IF wel_message-msgid = '/DMO/CM_FLIGHT_LEGAC'.
          IF wel_message-msgno = '009' OR  wel_message-msgno = '016' OR  wel_message-msgno = '017'.
            DATA(wl_cause) = if_abap_behv=>cause-not_found.

          ELSEIF wel_message-msgno = '032'.
            wl_cause = if_abap_behv=>cause-locked.
          ELSEIF wel_message-msgno = '046'.
            wl_cause = if_abap_behv=>cause-unauthorized.
          ENDIF.
        ENDIF.
        APPEND VALUE #( %cid = iv_cid travelId = iv_travel  %fail = VALUE #( cause = wl_cause  )
        ) TO et_fail_msg.
        ev_fail = abap_true.
      ENDIF.

      IF wel_message-msgid = '/DMO/CM_FLIGHT_LEGAC'.
        IF wel_message-msgno = '009' OR  wel_message-msgno = '016' OR  wel_message-msgno = '017'.
          wl_cause = if_abap_behv=>cause-not_found.

        ELSEIF wel_message-msgno = '032'.
          wl_cause = if_abap_behv=>cause-locked.
        ELSEIF wel_message-msgno = '046'.
          wl_cause = if_abap_behv=>cause-unauthorized.
        ENDIF.
      ENDIF.

      APPEND VALUE #( %cid = iv_cid travelId = iv_travel  %msg = new_message(
                                              id       = wel_message-msgid
                                              number   = wel_message-msgno
                                              severity = CONV #( wel_message-msgty )
                                              v1       = wel_message-msgv1
                                              v2       = wel_message-msgv2
                                              v3       = wel_message-msgv3
                                              v4       = wel_message-msgv4
                                            )
      ) TO et_report.

    ENDLOOP.


  ENDMETHOD.


  METHOD meth_travel_booking.
    DATA: wel_cause TYPE if_abap_behv=>t_fail_cause.

    LOOP AT it_messages INTO DATA(wel_message).

      IF wel_message-msgty = 'E' OR wel_message-msgty = 'A'.
        IF wel_message-msgid = '/DMO/CM_FLIGHT_LEGAC'.
          IF wel_message-msgno = '009' OR  wel_message-msgno = '016' OR  wel_message-msgno = '017'.
            IF iv_dependency = abap_true.
              DATA(wl_cause) = if_abap_behv=>cause-dependency.
            ELSE.
              wl_cause = if_abap_behv=>cause-not_found.
            ENDIF.
          ELSEIF wel_message-msgno = '032'.
            wl_cause = if_abap_behv=>cause-locked.
          ELSEIF wel_message-msgno = '046'.
            wl_cause = if_abap_behv=>cause-unauthorized.
          ENDIF.
        ENDIF.
        APPEND VALUE #( %cid = iv_cid travelId = iv_travel   %fail = VALUE #( cause = wl_cause   )
        ) TO et_fail_msg.
        ev_fail = abap_true.
      ENDIF.

      IF wel_message-msgid = '/DMO/CM_FLIGHT_LEGAC'.
        IF wel_message-msgno = '009' OR  wel_message-msgno = '016' OR  wel_message-msgno = '017'.
          wl_cause = if_abap_behv=>cause-not_found.

        ELSEIF wel_message-msgno = '032'.
          wl_cause = if_abap_behv=>cause-locked.
        ELSEIF wel_message-msgno = '046'.
          wl_cause = if_abap_behv=>cause-unauthorized.
        ENDIF.
      ENDIF.

      APPEND VALUE #( %cid = iv_cid travelId = iv_travel  %msg = new_message(
                                              id       = wel_message-msgid
                                              number   = wel_message-msgno
                                              severity = CONV #( wel_message-msgty )
                                              v1       = wel_message-msgv1
                                              v2       = wel_message-msgv2
                                              v3       = wel_message-msgv3
                                              v4       = wel_message-msgv4
                                            )
      ) TO et_report.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_ztravel_unmanaged IN LOCAL MODE
    ENTITY travel
    FIELDS (  TravelId overallstatus )
    WITH CORRESPONDING #(  keys ) RESULT DATA(Wtl_data).

    LOOP AT wtl_data INTO DATA(wel_data).

      IF requested_features-%assoc-_Booking = '01'.
        APPEND VALUE #(   %key = wel_data-%key  %assoc-_Booking = COND #(  WHEN wel_data-overallstatus = 'P' OR wel_data-overallstatus = 'X'
        THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )  )  TO result.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
