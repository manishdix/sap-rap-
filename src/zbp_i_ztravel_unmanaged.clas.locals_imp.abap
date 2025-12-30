CLASS lsc_ZI_ZTRAVEL_UNMANAGED DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_ZTRAVEL_UNMANAGED IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD adjust_numbers.
    DATA: wtl_travel_mapping  TYPE /dmo/if_flight_legacy=>tt_ln_travel_mapping,
          wtl_booking_mapping TYPE /dmo/if_flight_legacy=>tt_ln_booking_mapping,
          wtl_supppl          TYPE /dmo/if_flight_legacy=>tt_ln_bookingsuppl_mapping.

    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_ADJ_NUMBERS'
      IMPORTING
        et_travel_mapping       = wtl_travel_mapping
        et_booking_mapping      = wtl_booking_mapping
        et_bookingsuppl_mapping = wtl_supppl.

    LOOP AT wtl_travel_mapping INTO DATA(wel_travel).
      APPEND VALUE #( %tmp-travelid = wel_travel-preliminary travelId = wel_travel-final ) TO mapped-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD save.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.
  ENDMETHOD.

  METHOD cleanup.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_INITIALIZE'.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
