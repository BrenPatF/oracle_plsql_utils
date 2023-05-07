<#**************************************************************************************************
Name: Test-Get-UT_TemplateObject.ps1        Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the 'Trapit Utils' project in the powershell repository 'Powershell Utilities'.
The project has utility functions for unit testing following the Math Function Unit Testing design
pattern.

    GitHub: https://github.com/BrenPatF/powershell_utils

The design pattern involves the use of JSON files for storing test scenario and metadata, with an
input file including expected results, and an output file that has the actual results merged in.

The core utility module, TrapitUtils, has two main entry point functions to facilitate the design
pattern.

Write-UT_Template writes a template for the unit test scenarios JSON file based on two simple input
csv files holding the specific group/field structure for input and output groups. It performs the
'impure' reading and writing parts of the process, and calls a pure function, Get-UT_TemplateObject,
to do most of the logic. This was designed with the Functional Programming idea in mind that pure
functions are preferable to impure ones, and that we should try to organise our code accordingly. In
this way we can unit test the pure function more easily, while there is little complexity in the 
impure one, and it may not need explicit unit testing.

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
|  Test-ColGroup                   |  ColGroup     | module, with logging to file. Example of      |
|  Run-Test-ColGroup               |               | testing impure units, and error display       |
|----------------------------------|---------------|-----------------------------------------------|
|                                  |  Utils        | General utility functions                     |
| *Test-Get-UT_TemplateObject*     |---------------|-----------------------------------------------|
|  Run-Test-Get-UT_TemplateObject  |               | Trapit unit testing utility functions         |
|----------------------------------|  TrapitUtils  |-----------------------------------------------|
|  Install-TrapitUtils             |               | Installer copies module to Powershell path    |
====================================================================================================
This file contains a unit test script for the Get-UT_TemplateObject function.

The script contains a function, purelyWrap-Unit, that takes a scenario input object containing a
list of records for each input group, formatted as delimited strings. The function makes calls to
the functions in the unit under test and returns an object containing a list of records for each
output group, formatted as delimited strings.

The function is 'externally pure' in the sense that it is deterministic, interacts externally via
paameters and return value, and any file output is reverted before exit.

The main section of the script is a call to a utility function, passing in the names of input and
output JSON files, and the function. The utility function reads the input file, calls the function
passed within a loop over the input scenarios, accumulating the output scenarios containing both
expected and actual results, and finally writes the output JSON file.

A separate javascript program is used to read the output JSON file and produce formatted output in
text and HTML formats.

To run from the root folder:

    $ unit_test/Test-Get-UT_TemplateObject
**************************************************************************************************#>
Import-Module TrapitUtils
$DELIM = ';'
<#**************************************************************************************************

getGroupObjLis: Returns a list of objects from list of delimited group/field strings

**************************************************************************************************#>
function getGroupObjLis($strLis) { # list of delimited group/field/value strings
    $objLis = @()
    foreach ($s in $strLis) {
        $fields = $s.Split($DELIM)
        $objLis += @{'group' = $fields[0]; 'field' = $fields[1]; 'value' = $fields[2]}
    }
    $objLis
}
<#**************************************************************************************************

getSceObjLis: Returns a list of objects from list of delimited Category Set/Scenario/Active strings

**************************************************************************************************#>
function getSceObjLis($strLis) { # list of delimited Category Set/Scenario/Active strings
    $objLis = @()
    foreach ($s in $strLis) {
        $fields = $s.Split($DELIM)
        $objLis += @{'Category Set' = $fields[0]; 'Scenario' = $fields[1]; 'Active' = $fields[2]}
    }
    $objLis
}
<#**************************************************************************************************

getGroupFieldStrLis: Returns a list of delimited group/field strings from an object with group name
                     for key, and list of fields names for value

**************************************************************************************************#>
function getGroupFieldStrLis($obj) { # object has a key and a value that is an array of strings
    [String[]]$strLis = @()
    foreach ($o in $obj.PSObject.Properties) {
        foreach ($v in $o.value) {
            $strLis += $o.name + $DELIM + $v
        }
    }
    $strLis
}
<#**************************************************************************************************

purelyWrap-Unit: Design pattern has the unit under test calls wrapped in a 'pure' function, called
                 once per scenario, with the output 'actuals' arrays including everything affected
                 by the uut, whether as output parameters, or files, etc. The inputs are also 
                 extended from the uut parameters to include any other effective inputs.

                 In this case, the wrapper function makes a call to the uut, passing in input and
                 output lists of objects constructed from the input lists of delimited strings, and
                 possibly delimiter. A local function turns nested object lists within the returned
                 object into lists of delimited strings.

                 These lists of delimited strings are assigned as values to an object with key as 
                 group name in each case, as the return value

**************************************************************************************************#>
function purelyWrap-Unit($inpGroups) { # input scenario groups

    $scalars = $inpGroups.'Scalars'
    if ($scalars.length -eq 0) { # either empty or contains a delimiter
         $delimiter = '|'
    } else {
         $delimiter = $scalars[0]
    }
    $utObj = Get-UT_TemplateObject (getGroupObjLis $inpGroups.'Input Group') `
                                   (getGroupObjLis $inpGroups.'Output Group') `
                                   $delimiter `
                                   (getSceObjLis $inpGroups.'Scenarios')
    [String[]]$inpLis = @()
    [String[]]$outLis = @()
    [String[]]$sceLis = @()
    foreach ($p in $utObj.scenarios.PsObject.Properties) {
        $inpLis += getGroupFieldStrLis $p.value.inp | %{$p.name + $DELIM + $_}
        $outLis += getGroupFieldStrLis $p.value.out | %{$p.name + $DELIM + $_}
        $sceLis += $p.value.category_set + $DELIM + $p.name + $DELIM + $p.value.active_yn
    }
    [String[]]$metaInpLis = @()                        # direct assignment can lead to null object
    $metaInpLis += getGroupFieldStrLis $utObj.meta.inp # iso empty array

    [String[]]$metaOutLis = @()
    $metaOutLis += getGroupFieldStrLis $utObj.meta.out
    #      Object key (group name)  Private function    Returned group object = key + list of strings
    [PSCustomObject]@{
          'Meta Input Group'      = $metaInpLis
          'Meta Output Group'     = $metaOutLis
          'Scenarios'             = $sceLis
          'Scenario Input Group'  = $inpLis
          'Scenario Output Group' = $outLis
    }
}
# one line main section passing in input and output file names, and the local 'pure' function to unit test utility
Test-Unit ($PSScriptRoot + '/get_ut_template_object.json') ($PSScriptRoot + '/get_ut_template_object_out.json') `
          ${function:purelyWrap-Unit}