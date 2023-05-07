<#**************************************************************************************************
Name: ColGroup.psm1                         Author: Brendan Furey                  Date: 05-Apr-2021

Component module in the 'Trapit Utils' project in the powershell repository 'Powershell Utilities'.
The project has utility functions for unit testing following the Math Function Unit Testing design
pattern.

    GitHub: https://github.com/BrenPatF/powershell_utils

The design pattern involves the use of JSON files for storing test scenario and metadata, with an
input file including expected results, and an output file that has the actual results merged in.

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
====================================================================================================
| Script (.ps1)                | Module (.psm1) | Notes                                            |
|==================================================================================================|
|  Show-HelloWorld             |                | Simple Hello World program done as pure function |
|  Test-HelloWorld             |  HelloWorld    | to allow for unit testing as a simple edge case  |
|------------------------------|----------------|--------------------------------------------------|
|  Show-ColGroup               | *ColGroup*     | Simple file-reading and group-counting module,   |
|  Test-ColGroup               |                | with logging to file. Example of testing impure  |
|                              |                | units, and error display                         |
|------------------------------|----------------|--------------------------------------------------|
|                              |  Utils         | General utility functions                        |
|  Test-Get-UT_TemplateObject  |----------------|--------------------------------------------------|
|                              |                | Trapit unit testing utility functions            |
|------------------------------|  TrapitUtils   |--------------------------------------------------|
|  Install-TrapitUtils         |                | Install script copies module to Powershell path  |
====================================================================================================
This file contains a simple file-reading and group-counting module, with logging to file. Example of 
testing impure units, and error display.
**************************************************************************************************#>
Import-Module Utils
<#**************************************************************************************************

readList: Private function returns the key-value map of (string, count)

**************************************************************************************************#>
function readList($file,  # csv file
                  $delim, # delimiter
                  $col) { # column header
    $objLis = Get-ObjLisFromCsv $file $delim
    $counter = @{}
    foreach ($o in $objLis) {
        $key = $o.$col
        $val = If ($counter.$key -eq $null) { 1 } Else { $counter.$key + 1 }
        $counter.$key = $val
    }
    $counter
}
Class ColGroup {

    [hashtable]$counter
    [int]$maxLen
    <#**************************************************************************************************
    ColGroup: Constructor sets the key-value map of (string, count), and the maximum key length 
    **************************************************************************************************#>
    ColGroup($file,  # csv file
             $delim, # delimiter
             $col) { # column header
#        ((get-date -format u) -replace ".$") + ": File " + $file + `
#            ", delimiter '" + $delim + "', column " + $col + "`n") `
        ((get-date -format u) -replace ".$") + ": File " + $file +", delimiter '" + $delim + "', column " + $col | Out-File -FilePath ($file + '.log') -encoding utf8 -Append
        $this.counter = readList $file $delim $col
        $this.maxLen = ($this.counter.keys | measure-object -property length -maximum).maximum
    }
    <#**************************************************************************************************

    WriteList: Prints the key-value list of (string, count) sorted as specified

    **************************************************************************************************#>
    [String[]]WriteList($sortBy,                # sort by descriptor
                        [Object[]]$keyValues) { # list of key/value objects

        $strLis = Get-Heading ('Counts sorted by ' + $sortBy)
        $strLis += Get-ColHeaders @(@('Team', -$this.maxLen), @('#apps', 5))
        foreach ($kv in $keyValues) {

            $strLis += ("`n" + (Get-2LisAsLine @(@($kv.name, -$this.maxLen), @($kv.value, 5))))

        }
        return $strLis
    }
    <#**************************************************************************************************

    ListAsIs: Returns the key-value list of (string, count) unsorted

    **************************************************************************************************#>
    [Object[]]ListAsIs() {

        return $this.counter.getenumerator() | %{$_}
    }
    <#**************************************************************************************************

    SortByKey, SortByValue: Returns the key-value list of (string, count) sorted by key or value

    **************************************************************************************************#>
    [Object[]]SortByKey() {
        return $this.counter.getenumerator() | sort-object -property name
    }
    [Object[]]SortByValue() {
        return $this.counter.getenumerator() | sort-object -property value, name
    }
}