CREATE OR REPLACE PACKAGE TT_Utils AS
/***************************************************************************************************
Name: tt_utils.pks                     Author: Brendan Furey                       Date: 26-May-2019

Package body component in the oracle_plsql_utils module. The module comprises a set of generic 
user-defined Oracle types and a PL/SQL package of functions and procedures of general utility.

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There is an example main program and package showing how to use the Utils package, and a unit test
program. Unit testing is optional and depends on the module trapit_oracle_tester.
====================================================================================================
|  Main/Test .sql  |  Package    |  Notes                                                          |
|==================================================================================================|
|  main_col_group  |  Col_Group  |  Example showing how to use the Utils package procedures and    |
|                  |             |  and functions. Col_Group is a simple file-reading and          |
|                  |             |  group-counting package also used as an example in other modules|
|------------------|-------------|-----------------------------------------------------------------|
|  r_tests         | *TT_Utils*  |  Unit testing the Utils package. Trapit is installed as a       |
|                  |  Trapit     |  separate module                                                |
====================================================================================================

This file has the TT_Utils unit test package spec. Note that the test package is called by the unit
test utility package Trapit, which reads the unit test details from a table, tt_units, populated by
the install scripts.

The test program follows 'The Math Function Unit Testing design pattern':

    GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

Note that the unit test program generates an output file, tt_utils.test_api_out.json, that is 
processed by a separate nodejs program, npm package trapit (see README for further details).

The output JSON file contains arrays of expected and actual records by group and scenario, in the
format expected by the nodejs program. This program produces listings of the results in HTML and/or
text format, and a sample set of listings is included in the folder test_data\test_output

***************************************************************************************************/

FUNCTION Purely_Wrap_Utils(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr;

END TT_Utils;
/
