CREATE OR REPLACE PACKAGE Trapit AS
/***************************************************************************************************
Name: trapit.pks                       Author: Brendan Furey                       Date: 26-May-2019

Package spec component in the 'Trapit - Oracle PL/SQL Unit Testing' module, which facilitates unit
testing in Oracle PL/SQL following 'The Math Function Unit Testing design pattern', as described
here: 

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

GitHub project for Oracle PL/SQL:

    https://github.com/BrenPatF/trapit_oracle_tester

At the heart of the design pattern there is a language-specific unit testing driver function. This
function reads an input JSON scenarios file, then loops over the scenarios making calls to a
function passed in as a parameter from the calling script. The passed function acts as a 'pure'
wrapper around calls to the unit under test. It is 'externally pure' in the sense that it is
deterministic, and interacts externally only via parameters and return value. Where the unit under
test reads inputs from file the wrapper writes them based on its parameters, and where the unit
under test writes outputs to file the wrapper reads them and passes them out in its return value.
Any file writing is reverted before exit.

The driver function accumulates the output scenarios containing both expected and actual results
in an object, from which a JavaScript function writes the results in HTML and text formats.

In testing of non-JavaScript programs, the results object is written to a JSON file to be passed
to the JavaScript formatter. In Oracle PL/SQL, a PowerShell utility is used to automate the running
of the PL/SQL function, Trapit_Run.Test_Output_Files to write the JSON files for a unit test group,
then call the JavaScript formatter, format-external-file.js. The Oracle implementation differs from
those for scripting languages in two other ways:

1. Dynamic SQL replaces the passing of a function as a parameter
2. A database table is used to store the function names by unit test group

====================================================================================================
|  Package     |  Notes                                                                            |
|==================================================================================================|
| *Trapit*     |  Unit test utility package (Definer rights)                                       |
|--------------|-----------------------------------------------------------------------------------|
|  Trapit_Run  |  Unit test driver package (Invoker rights)                                        |
|--------------|-----------------------------------------------------------------------------------|
|  TT_Trapit   |  Unit test package for testing the generic unit test API, Trapit_Run.Run_A_Test   |
====================================================================================================

This file has the package spec for Trapit, the unit test utility package. See README for API 
specification, and the other modules mentioned there for examples of use

***************************************************************************************************/
FUNCTION Get_Inputs(
            p_unit_test_package_nm         VARCHAR2,
            p_purely_wrap_api_function_nm  VARCHAR2)
            RETURN                         L4_chr_arr;
PROCEDURE Set_Outputs(
            p_unit_test_package_nm         VARCHAR2,
            p_purely_wrap_api_function_nm  VARCHAR2,
            p_title                        VARCHAR2 := NULL,
            p_act_3lis                     L3_chr_arr,
            p_err_2lis                     L2_chr_arr);
PROCEDURE Add_Ttu(
            p_unit_test_package_nm         VARCHAR2,
            p_purely_wrap_api_function_nm  VARCHAR2, 
            p_group_nm                     VARCHAR2,
            p_active_yn                    VARCHAR2, 
            p_input_file                   VARCHAR2,
            p_title                        VARCHAR2 := NULL);
FUNCTION Get_Active_TT_Units(
            p_group_nm                     VARCHAR2)
            RETURN                         L1_chr_arr PIPELINED;
FUNCTION Set_Active_YNs (
            p_group_nm                     VARCHAR2,
            p_unit_test_package_nm         VARCHAR2 := NULL, 
            p_purely_wrap_api_function_nm  VARCHAR2 := NULL,
            p_scenario_nm                  VARCHAR2 := NULL,
            p_yn                           VARCHAR2 := 'Y')
            RETURN                         PLS_INTEGER;

END Trapit;
/
SHOW ERROR