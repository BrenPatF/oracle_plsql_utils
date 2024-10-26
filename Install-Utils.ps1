<#**************************************************************************************************
Name: Install-Utils.ps1                 Author: Brendan Furey                      Date: 20-Oct-2024

Install script for Oracle PL/SQL Utils module

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

====================================================================================================
| Script (.ps1)       | Module (.psm1) | Notes                                                     |
|==================================================================================================|
| *Install-Utils*     | OracleUtils    | Install script for Oracle PL/SQL Utils module             |
|---------------------|----------------------------------------------------------------------------|
|  Test-Format-Utils  | TrapitUtils    | Script to test and format results for Oracle PL/SQL       |
|                     |                | Utils module                                              |
|---------------------|----------------|-----------------------------------------------------------|
|  Format-JSON-Utils  | TrapitUtils    | Script to create template for unit test JSON input        |
|                     |                | file for Oracle PL/SQ Utils module                        |
====================================================================================================

**************************************************************************************************#>
Import-Module .\powershell_utils\OracleUtils\OracleUtils
$inputPath = 'c:/input'
$fileLis = @('./unit_test/tt_utils.purely_wrap_utils_inp.json',
             './fantasy_premier_league_player_stats.csv')

$sysSchema = 'sys'
$libSchema = 'lib'
$appSchema = 'app'

$installs = @(#@{folder = '.';                     script = 'drop_utils_users';  schema = $sysSchema; prmLis = @($libSchema, $appSchema)},
              @{folder = '.';                     script = 'install_sys';       schema = $sysSchema; prmLis = @($libSchema, $appSchema, $inputPath)},
              @{folder = 'lib';                   script = 'install_utils';     schema = $libSchema; prmLis = @($appSchema)},
              @{folder = 'install_ut_prereq\lib'; script = 'install_lib_all';   schema = $libSchema; prmLis = @($appSchema)},
              @{folder = 'install_ut_prereq\app'; script = 'c_syns_all';        schema = $appSchema; prmLis = @($libSchema)},
              @{folder = 'lib';                   script = 'install_utils_tt';  schema = $libSchema; prmLis = @()},
              @{folder = 'app';                   script = 'install_col_group'; schema = $appSchema; prmLis = @($libSchema)},
              @{folder = '.';                     script = 'l_objects';         schema = $sysSchema; prmLis = @($sysSchema)},
              @{folder = '.';                     script = 'l_objects';         schema = $libSchema; prmLis = @($libSchema)},
              @{folder = '.';                     script = 'l_objects';         schema = $appSchema; prmLis = @($appSchema)})
Install-OracleApp $inputPath $fileLis $installs
