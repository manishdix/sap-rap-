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
            REPORTED-zi_ztravel_managed_d = VALUE #( BASE REPORTED-zi_ztravel_managed_d  (  %tky  = wel_entities-%tky
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

ENDCLASS.
