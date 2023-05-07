<#**************************************************************************************************
Name: Test-ColGroup.ps1                     Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the 'Trapit Utils' project in the powershell repository 'Powershell Utilities'.
The project has utility functions for unit testing following the Math Function Unit Testing design
pattern.

    GitHub: https://github.com/BrenPatF/powershell_utils

The design pattern involves the use of JSON files for storing test scenario and metadata, with an
input file including expected results, and an output file that has the actual results merged in.
The output JSON file is processed by a JavaScript program that formats the results in HTML and text.

The core utility module, TrapitUtils, has two main entry point functions to facilitate the design
pattern.

Write-UT_Template writes a template for the unit test scenarios JSON file based on three input csv
files holding the specific group/field structure for input and output groups, and a scenarios list.
It performs the 'impure' reading and writing parts of the process, and calls a pure function, 
Get-UT_TemplateObject, to do most of the logic. This was designed with the Functional Programming
idea in mind that pure functions are preferable to impure ones, and that we should try to organise
our code accordingly. In this way we can unit test the pure function more easily, while there is
little complexity in the impure one, and it may not need explicit unit testing.

Test-Unit is a utility that is called as effectively the main function of any specific unit test
script. It reads the input JSON scenarios file, then loops over the scenarios making calls to a 
function passed in as a parameter from the calling script. The function acts as a 'pure' wrapper
around calls to the unit under test. It is 'externally pure' in the sense that it is deterministic,
and interacts externally only via parameters and return value. Where the unit under test reads 
inputs from file the wrapper writes them based on its parameters, and where the unit under test 
writes outputs to file the wrapper reads them and passes them out in its return value. Any file
writing is reverted before exit. Test-Unit is called as part of any unit test driver script,
including the one that tests Get-UT_TemplateObject, and is considered to be thereby tested
implicitly.

The table shows the driver scripts for the relevant modules: There are two examples of use, with
main and test drivers; a test driver for the Get-UT_TemplateObject function; and an install script.
In addition there is a "Run-" script for each test driver that calls the driver, then calls the
JavaScript formatter.
====================================================================================================
|  Script (.ps1)                   | Module (.psm1)| Notes                                         |
|==================================================================================================|
|  Show-HelloWorld                 |               | Simple Hello World program done as pure       |
|  Test-HelloWorld                 |  HelloWorld   | function to allow for unit testing as a       |
|  Run-Test-HelloWorld             |               | simple edge case                              |
|----------------------------------|---------------|-----------------------------------------------|
|  Show-ColGroup                   |               | Simple file-reading and group-counting        |
| *Test-ColGroup*                  |  ColGroup     | module, with logging to file. Example of      |
|  Run-Test-ColGroup               |               | testing impure units, and error display       |
|----------------------------------|---------------|-----------------------------------------------|
|                                  |  Utils        | General utility functions                     |
|  Test-Get-UT_TemplateObject      |---------------|-----------------------------------------------|
|  Run-Test-Get-UT_TemplateObject  |               | Trapit unit testing utility functions         |
|----------------------------------|  TrapitUtils  |-----------------------------------------------|
|  Install-TrapitUtils             |               | Installer copies module to Powershell path    |
====================================================================================================
This file contains a unit test script for a simple file-reading and group-counting module, with
logging to file. Note that this example has two deliberate errors to show how these are displayed.

To run from the root folder:

    $ examples/colgroup/Test-ColGroup
**************************************************************************************************#>
Using Module './ColGroup.psm1'
Import-Module TrapitUtils

$INPUT_FILE,                       $LOG_FILE                             =
($PSScriptRoot + '/ut_group.csv'), ($PSScriptRoot + '/ut_group.csv.log')

$GRP_LOG, $GRP_SCA,  $GRP_LIN, $GRP_LAI,   $GRP_SBK,    $GRP_SBV,      $GRP_ERR        =
'Log',    'Scalars', 'Lines',  'listAsIs', 'sortByKey', 'sortByValue', 'Error Message'
$DELIM = '|'

function fromCSV($csv,  # string of delimited values
                 $col) { # 0-based column index
    $csv.Split($DELIM)[$col]
}
function setup($inpGroups) { # input scenario groups
    [String[]]$linesArr = @()
    $linesArr += $inpGroups.'Lines'
    $linesArr | Out-File -FilePath $INPUT_FILE -encoding utf8
    if ($inpGroups[$GRP_LOG].length -gt 0) {
        $inpGroups[$GRP_LOG].Join('`n') | Out-File -FilePath $LOG_FILE -encoding utf8
    }
    [ColGroup]::New($INPUT_FILE, (fromCSV $inpGroups.'Scalars'[0] 0), (fromCSV $inpGroups.'Scalars'[0] 1))
}
function teardown {
    Start-Sleep -Seconds 0.1 # to avoid locking issue
    Remove-Item $INPUT_FILE
    if (Test-Path -Path $LOG_FILE) {Remove-Item $LOG_FILE}
}
function purelyWrap-Unit($inpGroups) { # input scenario groups
    [string[]]$grpLog = @()
    [string[]]$grpLai = @()
    [string[]]$grpSbk = @()
    [string[]]$grpSbv = @()
    try {
        $colGroup  = setup $inpGroups
        $linesArr  = [string[]](Get-Content -path $LOG_FILE)
        $lastLine  = $linesArr[$linesArr.length - 1]
        $diffDate  = ((date) - [datetime]$lastLine.SubString(0,19)).TotalMilliseconds
        $grpLog = ($linesArr.length).ToString() + $DELIM + $diffDate.ToString() + $DELIM + ($lastLine -Replace "\\", "-")
        $len = $colGroup.ListAsIs().length
        $grpLai = $len.ToString()
        if ($len -ne 0) {
            $grpSbk = $colGroup.SortByKey() | %{$_.name + $DELIM + $_.value}
            $grpSbv = $colGroup.SortByValue() | %{$_.name + $DELIM + $_.value}
        }
        [PSCustomObject]@{
            $GRP_LOG = $grpLog
            $GRP_LAI = $grpLai
            $GRP_SBK = $grpSbk
            $GRP_SBV = $grpSbv
        }
    }
    finally {
        teardown
    }
}
# one line main section passing in input and output file names, and the local 'pure' function to unit test utility
Test-Unit ($PSScriptRoot + '/colgroup.json') ($PSScriptRoot + '/colgroup_out.json') `
          ${function:purelyWrap-Unit}