CLASS zcl_test_class11 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  class-methods meth1
        changing VALUE(var_change) TYPE i.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_test_class11 IMPLEMENTATION.

  METHOD meth1.

    var_change = 2.

  ENDMETHOD.

ENDCLASS.
