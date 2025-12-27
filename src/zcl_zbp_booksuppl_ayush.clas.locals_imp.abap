CLASS lhc_zi_zbooksuppl_tech_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculate_total_price FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_ZBOOKSUPPL_TECH_M~calculate_total_price.

ENDCLASS.

CLASS lhc_zi_zbooksuppl_tech_m IMPLEMENTATION.

  METHOD calculate_total_price.
  MODIFY ENTITY IN LOCAL MODE zi_ztravel_tech_m
    EXECUTE recal_price
    FROM CORRESPONDING #( keys ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
