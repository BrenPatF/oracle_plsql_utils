@..\initspool install_utils_tt
/***************************************************************************************************
Name: install_utils_tt.sql             Author: Brendan Furey                       Date: 26-May-2019

Installation script for the unit test components in the oracle_plsql_utils module. It requires a 
minimum Oracle database version of 12.2.

This module comprises a set of generic user-defined Oracle types and a PL/SQL package of functions
and procedures of general utility.

	GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There are install scripts for sys, lib and app schemas. However the base code alone can be installed
via install_utils.sql in an existing schema without executing the other scripts.

If the unit test code is to be installed, trapit_oracle_tester module must be installed after the 
base install: 

	GitHub: https://github.com/BrenPatF/trapit_oracle_tester

====================================================================================================
|  Script                  |  Notes                                                                |
|==================================================================================================|
|  install_sys.sql         |  sys script creates: lib and app schemas; input_dir directory; grants |
|--------------------------|-----------------------------------------------------------------------|
|  install_utils.sql       |  Creates base components, including Utils package, in lib schema      |
|--------------------------|-----------------------------------------------------------------------|
| *install_utils_tt.sql*   |  Creates unit test components that require a minimum Oracle database  |
|                          |  version of 12.2 in lib schema                                        |
|--------------------------|-----------------------------------------------------------------------|
|  grant_utils_to_app.sql  |  Grants privileges on Utils components from lib to app schema         |
|--------------------------|-----------------------------------------------------------------------|
|  install_col_group.sql   |  Creates components for the Col_Group example in app schema           |
|--------------------------|-----------------------------------------------------------------------|
|  c_utils_syns.sql        |  Creates synonyms for Utils components in app schema to lib schema    |
====================================================================================================

This file has the install script for the unit test components in the lib schema. It requires a
minimum Oracle database version of 12.2, owing to the use of v12.2 PL/SQL JSON features.

Components created, with NO synonyms or grants - only accessible within lib schema:

    Packages      Description
    ============  ==================================================================================
    TT_Utils      Unit test package for Utils. Uses Oracle v12.2 JSON features

    Metadata      Description
    ============  ==================================================================================
    tt_units      Record for package, procedure ('TT_Utils', 'Test_API'). The input JSON file
                  must first be placed in the OS folder pointed to by INPUT_DIR directory

***************************************************************************************************/

PROMPT Add the tt_units record, reading in JSON file from INPUT_DIR
DEFINE LIB=lib
DECLARE
BEGIN

  Trapit.Add_Ttu('TT_UTILS', 'Purely_Wrap_Utils', '&LIB', 'Y', 'tt_utils.purely_wrap_utils_inp.json');

END;
/
PROMPT Create package TT_Utils
@tt_utils.pks
@tt_utils.pkb

@..\endspool
exit