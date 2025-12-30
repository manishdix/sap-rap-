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

    TYPES: tt_failed   TYPE TABLE FOR FAILED EARLY zi_ztravel_unmanaged\\travel,
           tt_reported TYPE TABLE FOR REPORTED EARLY zi_ztravel_unmanaged\\travel.

    METHODS meth_travel
      IMPORTING
        iv_cid      TYPE abp_behv_cid OPTIONAL
        it_messages TYPE /dmo/t_message
        iv_travel   TYPE /dmo/travel_id OPTIONAL
      EXPORTING
        et_fail_msg TYPE tt_failed
        et_report   TYPE tt_reported
        ev_fail     TYPE abap_boolean.

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
      wel_travel = CORRESPONDING #( wel_entities MAPPING FROM ENTITY ).
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

    LOOP AT entities INTO DATA(wel_entities1).
      wel_travel = CORRESPONDING #( wel_entities1 MAPPING FROM ENTITY ).
      DATA: wel_travelx TYPE /dmo/s_travel_inx.

      wel_travelx = CORRESPONDING #( wel_entities1 MAPPING FROM ENTITY ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = wel_travel
          is_travelx  = wel_travelx
        IMPORTING
          es_travel   = wel_travel_out
          et_messages = wtl_messages.

      CALL METHOD meth_travel
        EXPORTING
          iv_cid      = wel_entities-%cid
          iv_travel   = wel_entities-TravelId
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

  METHOD delete.
  ENDMETHOD.

  METHOD read.

    LOOP AT keys INTO DATA(wel_keys).
      DATA: wel_travel             TYPE /dmo/travel,
            wel_booking            TYPE /dmo/t_booking,
            wtl_booking_supplement TYPE /dmo/t_booking_supplement,
            wtl_messages           TYPE /dmo/t_message,
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

      APPEND CORRESPONDING #(  wel_travel ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    DATA: wol_lock_object TYPE REF TO if_abap_lock_object.

    TRY.
        cl_abap_lock_object_factory=>get_instance(
          EXPORTING
            iv_name        = '/DMO/ETRAVEL'
          RECEIVING
            ro_lock_object = wol_lock_object
        ).
      CATCH cx_abap_lock_failure.
        "handle exception
    ENDTRY.

    LOOP AT keys INTO DATA(wel_keys).
      TRY.
          wol_lock_object->enqueue(
          it_table_mode = VALUE #(  (  mode = 'E'  ) )
          it_parameter  = VALUE #(  (  name = 'TRAVEL_ID' value = REF #( wel_keys-TravelId )  )
           ) ).
        CATCH cx_abap_foreign_lock cx_abap_lock_failure.

      ENDTRY.

    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Booking.
  ENDMETHOD.

  METHOD cba_Booking.
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

ENDCLASS.
