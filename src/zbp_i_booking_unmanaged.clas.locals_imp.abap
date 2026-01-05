CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE booking.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE booking.

    METHODS read FOR READ
      IMPORTING keys FOR READ booking RESULT result.

    METHODS rba_Travel FOR READ
      IMPORTING keys_rba FOR READ booking\_Travel FULL result_requested RESULT result LINK association_links.

    TYPES: tt_failed   TYPE TABLE FOR FAILED EARLY zi_ztravel_unmanaged\\travel,
           tt_reported TYPE TABLE FOR REPORTED EARLY zi_ztravel_unmanaged\\travel.

    TYPES: tt_failed1   TYPE TABLE FOR FAILED EARLY zi_ztravel_unmanaged\\travel,
           tt_reported1 TYPE TABLE FOR REPORTED EARLY zi_ztravel_unmanaged\\travel.

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

CLASS lhc_booking IMPLEMENTATION.

  METHOD update.

    DATA: wel_travel      TYPE /dmo/s_travel_in,
          wel_travel_out  TYPE /dmo/travel,
          wtl_messages    TYPE /dmo/t_message,
          wtl_failed      TYPE TABLE FOR FAILED zi_ztravel_unmanaged,
          wtl_report      TYPE TABLE FOR REPORTED zi_ztravel_unmanaged,
          wl_fail         TYPE abap_boolean,
          wtl_booking     TYPE /dmo/t_booking_in,
          wel_booking     TYPE /dmo/s_booking_in,
          wtl_booking_out TYPE /dmo/t_booking,
          wtl_bookingx    TYPE /dmo/t_booking_inx,
          wel_bookingx    TYPE /dmo/s_booking_inx,
          wel_travelx     TYPE /dmo/s_travel_inx,
          wl_id           TYPE i.

    LOOP AT entities INTO DATA(wel_entities).

      wel_booking = CORRESPONDING #( wel_entities MAPPING FROM ENTITY USING CONTROL  ).
      wel_booking-travel_id = wel_entities-TravelId.
      wel_booking-booking_id = wel_entities-BookingId.
      wel_bookingx-_intx = CORRESPONDING #( wel_entities MAPPING FROM ENTITY USING CONTROL  ).
      wel_bookingx-action_code = if_abap_behv=>op-m-update.
      wel_bookingx-booking_id = wel_entities-BookingId.

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

  ENDMETHOD.

  METHOD delete.

    DATA: wel_travel      TYPE /dmo/s_travel_in,
          wel_travel_out  TYPE /dmo/travel,
          wtl_messages    TYPE /dmo/t_message,
          wtl_failed      TYPE TABLE FOR FAILED zi_ztravel_unmanaged,
          wtl_report      TYPE TABLE FOR REPORTED zi_ztravel_unmanaged,
          wl_fail         TYPE abap_boolean,
          wtl_booking     TYPE /dmo/t_booking_in,
          wel_booking     TYPE /dmo/s_booking_in,
          wtl_booking_out TYPE /dmo/t_booking,
          wtl_bookingx    TYPE /dmo/t_booking_inx,
          wel_bookingx    TYPE /dmo/s_booking_inx,
          wel_travelx     TYPE /dmo/s_travel_inx,
          wl_id           TYPE i.

    LOOP AT keys INTO DATA(wel_entities).

      wel_booking = CORRESPONDING #( wel_entities MAPPING FROM ENTITY  ).
      wel_booking-travel_id = wel_entities-TravelId.
      wel_booking-booking_id = wel_entities-BookingId.
      wel_bookingx-action_code = if_abap_behv=>op-m-delete.
      wel_bookingx-booking_id = wel_entities-BookingId.

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
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Travel.
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

ENDCLASS.
