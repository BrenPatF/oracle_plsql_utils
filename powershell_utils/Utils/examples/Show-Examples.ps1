<#**************************************************************************************************
Name: Show-Examples.ps1                     Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the Powershell Utilities module Utils. The module has general utility functions
for pretty-printing etc.

    GitHub: https://github.com/BrenPatF/powershell_utils

There is an examples main script and a unit test script. The examples script makes calls to an
example class module that uses the pretty-printing functions, and calls other functions directly.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://github.com/BrenPatF/trapit_nodejs_tester#trapit

====================================================================================================
| Script (.ps1)    | Module (.psm1) |  Notes                                                       |
|==================================================================================================|
|  Install-Utils   |                   Install script copies module to Powershell path             |
|------------------|-------------------------------------------------------------------------------|
|                  |  ColGroup      |  Simple file-reading and group-counting class module         |
| *Show-Examples*  |----------------|--------------------------------------------------------------|
|                  |                |                                                              |
|------------------|  Utils         |  General utility functions                                   |
|                  |                |                                                              |
|  Test-Utils      |----------------|--------------------------------------------------------------|
|                  |  Trapit-Utils  |  Trapit unit testing utility functions                       |
====================================================================================================

Main script for the examples of use. It demonstrates directly calls to:
    - Write-Debug
    - Get-Heading
    - Get-StrLisFromObjLis
    - Remove-ExtraLF
    - Install-Module

The ColGroup class demonstrate calls to:
    - Get-ObjLisFromCsv
    - Get-ColHeaders
    - Get-2LisAsLine

**************************************************************************************************#>
Using Module './ColGroup.psm1'
Import-Module Utils
$INPUT_FILE, $DELIM, $COL = ($PSScriptRoot + './fantasy_premier_league_player_stats.csv'), ',', 'team_name'

Get-Heading 'Demonstrate initial call to Write-Debug...'
'Write-Debug ''Debug'' $true'
Write-Debug 'Debug' $true

Get-Heading 'ColGroup constructor uses Get-ObjLisFromCsv...'
'$grp = [ColGroup]::New($INPUT_FILE, $DELIM, $COL)'
$grp = [ColGroup]::New($INPUT_FILE, $DELIM, $COL)

$meas = $grp.ListAsIs() | measure-object -property value -sum

Get-Heading 'Demonstrate subsequent call to Write-Debug...'
'Write-Debug (''Counted '' + $meas.count + '' teams, with '' + $meas.sum + '' appearances'')'
Write-Debug ('Counted ' + $meas.count + ' teams, with ' + $meas.sum + ' appearances')

Get-Heading 'ColGroup.WriteList uses the pretty-printing functions...'
'$grp.WriteList(''(as is)'', $grp.ListAsIs())'
$grp.WriteList('(as is)', $grp.ListAsIs())
$grp.WriteList('key',     $grp.SortByKey())
$grp.WriteList('value',   $grp.SortByValue())

Get-Heading 'Demonstrate call to Get-StrLisFromObjLis...'
'Get-StrLisFromObjLis @($exampleObj1, $exampleObj2)'
''
$exampleObj1 = [PSCustomObject]@{key11 = 'a'; key12 = 'b'} # keys from first object are included as first record
$exampleObj2 = [PSCustomObject]@{key21 = 'c'; key22 = 'd'} # keys from subsequent objects are not included

Get-StrLisFromObjLis @($exampleObj1, $exampleObj2)

Get-Heading 'Counts on content of debug.log before and after calling Remove-ExtraLF...'
'Remove-ExtraLF ''./debug.log'''
'Before:'
Get-Content -Raw './debug.log' | measure -Line -Character -Word

'After:'
Remove-ExtraLF './debug.log'
Get-Content -Raw './debug.log' | measure -Line -Character -Word

Get-Heading 'Content of debug.log...'
Get-Content './debug.log'

Get-Heading 'Demonstrate Install-Module...'
'Install-Module $PSScriptRoot ''ExampleModuleEmpty'''
Install-Module $PSScriptRoot 'ExampleModuleEmpty'

$psPathFirst = $env:psmodulepath.split(';')[0]
$newFolder = $psPathFirst + '\ExampleModuleEmpty'
$childs = Get-ChildItem -Path $newFolder -Recurse
("Installed in folder $newFolder...")
"$childs"
'Delete the installed module to clean up...'
Remove-Item -LiteralPath ($psPathFirst + '\ExampleModuleEmpty') -Force -Recurse