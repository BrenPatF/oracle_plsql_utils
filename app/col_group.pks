CREATE OR REPLACE PACKAGE Col_Group AS
/***************************************************************************************************
Name: col_group.pks                    Author: Brendan Furey                       Date: 29-Jan-2019

Package body component in oracle_plsql_utils module, also used in several other Oracle GitHub 
modules to illustrate their usages. The module comprises a set of generic user-defined Oracle types
and a PL/SQL package of functions and procedures of general utility.

GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There is an example main program and package showing how to use the Utils package, and a unit test
program. Unit testing is optional and depends on the module trapit_oracle_tester.
====================================================================================================
|  Main            |  Package    |  Notes                                                          |
|==================================================================================================|
|  main_col_group  | *Col_Group* |  Example showing how to use the Utils package procedures and    |
|                  |             |  functions. Package is simple file-reading and group-counting   |
|                  |             |  module also used as example in other modules                   |
|------------------|-------------|-----------------------------------------------------------------|
|  r_tests         |  TT_Utils   |  Unit testing the Utils package. Trapit is installed as a       |
|                  |  Trapit     |  separate module                                                |
====================================================================================================

This file has the example Col_Group package spec. The package reads delimited lines from file, and
counts values in a given column, with methods to return the counts in various orderings. It is used
as a simple example to illustrate usage of Utils and other utility-type packages.

***************************************************************************************************/

PROCEDURE Load_File(
	        p_file                         VARCHAR2,
	        p_delim                        VARCHAR2,
	        p_colnum                       PLS_INTEGER);
FUNCTION List_Asis
            RETURN                         chr_int_arr;
FUNCTION Sort_By_Key
            RETURN                         chr_int_arr;
FUNCTION Sort_By_Value
            RETURN                         chr_int_arr;

END Col_Group;
/
SHO ERR



