DEFINE LIB=&1
/***************************************************************************************************
Name: install_col_group.sql            Author: Brendan Furey                       Date: 17-Mar-2019

Installation script for the Col_Group example in the app schema in the oracle_plsql_utils module. 

This module comprises a set of generic user-defined Oracle types and a PL/SQL package of functions
and procedures of general utility.

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There are install scripts for sys, lib and app schemas. However the base code alone can be installed
via install_utils.sql in an existing schema without executing the other scripts.
====================================================================================================
|  Script                  |  Notes                                                                |
|==================================================================================================|
|  install_sys.sql         |  sys script creates: lib and app schemas; input_dir directory; grants |
|--------------------------|-----------------------------------------------------------------------|
|  install_utils.sql       |  Creates base components, including Utils package, in lib schema      |
|--------------------------|-----------------------------------------------------------------------|
|  install_utils_tt.sql    |  Creates unit test components that require a minimum Oracle database  |
|                          |  version of 12.2 in lib schema                                        |
|--------------------------|-----------------------------------------------------------------------|
|  grant_utils_to_app.sql  |  Grants privileges on Utils components from lib to app schema         |
|--------------------------|-----------------------------------------------------------------------|
| *install_col_group.sql*  |  Creates components for the Col_Group example in app schema           |
|--------------------------|-----------------------------------------------------------------------|
|  c_utils_syns.sql        |  Creates synonyms for Utils components in app schema to lib schema    |
====================================================================================================

This file has the install script for the Col_Group example in the app schema.

Components created, with NO grants - only accessible within app schema - and synonyms via 
c_utils_syns.sql:

    Synonyms            Description
    ==================  ============================================================================
    (Utils components)  See c_utils_syns.sql

    External Table      Description
    ==================  ============================================================================
    lines_et            Used to read in csv records from lines.csv placed in INPUT_DIR folder

    Packages            Description
    ==================  ============================================================================
    Col_Group           Package called by main_col_group as a simple example to illustrate usage of 
                        Utils package. Also used in other utility-type modules

***************************************************************************************************/
@..\initspool install_col_group

PROMPT Create Utils synonyms
PROMPT =====================
@c_utils_syns &LIB

PROMPT External table creation
PROMPT =======================
PROMPT Create lines_et
CREATE TABLE lines_et (
        line            VARCHAR2(400)
)
ORGANIZATION EXTERNAL ( 
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY input_dir
    ACCESS PARAMETERS (
            RECORDS DELIMITED BY NEWLINE
            FIELDS (
                line POSITION (1:4000) CHAR(4000)
            )
    )
    LOCATION ('lines.csv')
)
    REJECT LIMIT UNLIMITED
/
PROMPT Packages creation
PROMPT =================

PROMPT Create package Col_Group
@col_group.pks
@col_group.pkb

@..\endspool
exit