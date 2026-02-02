<#**************************************************************************************************
Name: Format-JSON-Utils.ps1             Author: Brendan Furey                      Date: 20-Oct-2024

Script to create template for unit test JSON input file for Oracle PL/SQL Utils module

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

====================================================================================================
| Script (.ps1)       | Module (.psm1) | Notes                                                     |
|==================================================================================================|
|  Install-Utils      | OracleUtils    | Install script for Oracle PL/SQL Utils module             |
|---------------------|----------------------------------------------------------------------------|
|  Test-Format-Utils  | TrapitUtils    | Script to test and format results for Oracle PL/SQL       |
|                     |                | Utils module                                              |
|---------------------|----------------|-----------------------------------------------------------|
| *Format-JSON-Utils* | TrapitUtils    | Script to create template for unit test JSON input        |
|                     |                | file for Oracle PL/SQ Utils module                        |
====================================================================================================

**************************************************************************************************#>
Import-Module ..\powershell_utils\TrapitUtils\TrapitUtils
Write-UT_Template 'tt_utils.purely_wrap_utils' ';'
