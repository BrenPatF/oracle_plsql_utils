CREATE OR REPLACE PACKAGE BODY Col_Group AS
/***************************************************************************************************
Name: col_group.pkb                    Author: Brendan Furey                       Date: 29-Jan-2019

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

This file has the example Col_Group package body. The package reads delimited lines from file, and
counts values in a given column, with methods to return the counts in various orderings. It is used
as a simple example to illustrate usage of Utils and other utility-type packages.

***************************************************************************************************/

g_chr_int_lis           chr_int_arr;
/***************************************************************************************************

Load_File: Reads file via external table, and stores counts of string values in input column into
           package array

***************************************************************************************************/
PROCEDURE Load_File(
            p_file                         VARCHAR2,       -- file name, including path
            p_delim                        VARCHAR2,       -- field delimiter
            p_colnum                       PLS_INTEGER) IS -- column number of values to be counted
BEGIN

  EXECUTE IMMEDIATE 'ALTER TABLE lines_et LOCATION (''' || p_file || ''')';

  WITH key_column_values AS (
    SELECT Substr(line, Instr(p_delim||line||p_delim, p_delim, 1, p_colnum),
                        Instr(p_delim||line||p_delim, p_delim, 1, p_colnum+1) - Instr(p_delim||line||p_delim, p_delim, 1, p_colnum) - Length(p_delim)) keyval
      FROM lines_et
  )
  SELECT chr_int_rec(keyval, COUNT(*))
    BULK COLLECT INTO g_chr_int_lis
    FROM key_column_values
   GROUP BY keyval;

END Load_File;

/***************************************************************************************************

List_Asis: Returns the key-value array of string, count as is, i.e. unsorted

***************************************************************************************************/
FUNCTION List_Asis 
            RETURN                         chr_int_arr IS -- key-value array unsorted
BEGIN

  RETURN g_chr_int_lis;

END List_Asis;

/***************************************************************************************************

Sort_By_Key: Returns the key-value array of (string, count) sorted by key

***************************************************************************************************/
FUNCTION Sort_By_Key 
            RETURN                         chr_int_arr IS -- key-value array sorted by key
  l_chr_int_lis chr_int_arr;
BEGIN

  SELECT chr_int_rec(t.chr_value, t.int_value)
    BULK COLLECT INTO l_chr_int_lis
    FROM TABLE (g_chr_int_lis) t
   ORDER BY t.chr_value;

  RETURN l_chr_int_lis;

END Sort_By_Key;

/***************************************************************************************************

Sort_By_Value: Returns the key-value array of (string, count) sorted by value

***************************************************************************************************/
FUNCTION Sort_By_Value 
           RETURN                          chr_int_arr IS -- key-value array sorted by value
  l_chr_int_lis chr_int_arr;
BEGIN

  SELECT chr_int_rec(t.chr_value, t.int_value)
    BULK COLLECT INTO l_chr_int_lis
    FROM TABLE (g_chr_int_lis) t
   ORDER BY t.int_value, t.chr_value;

  RETURN l_chr_int_lis;

END Sort_By_Value;

END Col_Group;
/
SHO ERR