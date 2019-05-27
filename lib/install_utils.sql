@..\initspool install_utils
/***************************************************************************************************
Name: install_utils.sql                Author: Brendan Furey                       Date: 26-May-2019

Installation script for the oracle_plsql_utils module, excluding the unit test components that
require a minimum Oracle database version of 12.2.

This module comprises a set of generic user-defined Oracle types and a PL/SQL package of functions
and procedures of general utility.

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There are install scripts for sys, lib and app schemas. However the base code alone can be installed
via install_utils.sql in an existing schema without executing the other scripts.

If the unit test code is to be installed, trapit_oracle_tester module must be installed after the 
base install: 

    https://github.com/BrenPatF/trapit_oracle_tester

====================================================================================================
|  Script                 |  Notes                                                                 |
|===================================================================================================
|  install_sys.sql        |  sys script creates: lib and app schemas; input_dir directory; grants  |
----------------------------------------------------------------------------------------------------
| *install_utils.sql*     |  Creates base components, including Utils package, in lib schema       |
----------------------------------------------------------------------------------------------------
|  install_utils_tt.sql   |  Creates unit test components that require a minimum Oracle database   |
|                         |  version of 12.2 in lib schema                                         |
----------------------------------------------------------------------------------------------------
|  install_col_group.sql  |  Creates components for the Col_Group example in the app schema        |
====================================================================================================

This file has the install script for the lib schema, excluding the unit test components that require
a minimum Oracle database version of 12.2. This script should work in prior versions of Oracle,
including v10 and v11 (although it has not been tested on them).

Components created, with public synonyms and grants to public:

    Types         Description
    ==========    ==================================================================================
    L1_chr_arr    Generic array of strings
    L1_num_arr    Generic array of number
    chr_int_rec   Object type of (char, int)-tuple
    chr_int_arr   Array of chr_int_rec

    Packages
    ==========
    Utils         General utility procedures and functions

***************************************************************************************************/

PROMPT Common type creation
PROMPT ====================

PROMPT Create type L1_chr_arr
CREATE OR REPLACE TYPE L1_chr_arr IS VARRAY(32767) OF VARCHAR2(32767)
/
CREATE OR REPLACE PUBLIC SYNONYM L1_chr_arr FOR L1_chr_arr
/
GRANT EXECUTE ON L1_chr_arr TO PUBLIC
/
PROMPT Create type L1_num_arr
CREATE OR REPLACE TYPE L1_num_arr IS VARRAY(32767) OF NUMBER
/
CREATE OR REPLACE PUBLIC SYNONYM L1_num_arr FOR L1_num_arr
/
GRANT EXECUTE ON L1_num_arr TO PUBLIC
/
DROP TYPE chr_int_arr
/
CREATE OR REPLACE TYPE chr_int_rec AS OBJECT (
  chr_value                     VARCHAR2(4000), 
  int_value                     INTEGER)
/
CREATE OR REPLACE PUBLIC SYNONYM chr_int_rec FOR chr_int_rec
/
GRANT EXECUTE ON chr_int_rec TO PUBLIC
/
CREATE TYPE chr_int_arr AS TABLE OF chr_int_rec
/
CREATE OR REPLACE PUBLIC SYNONYM chr_int_arr FOR chr_int_arr
/
GRANT EXECUTE ON chr_int_arr TO PUBLIC
/
PROMPT Packages creation
PROMPT =================

PROMPT Create package Utils
@utils.pks
@utils.pkb
GRANT EXECUTE ON Utils TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM Utils FOR Utils
/
@..\endspool