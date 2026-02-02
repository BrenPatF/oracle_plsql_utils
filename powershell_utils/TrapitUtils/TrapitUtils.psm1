<#************************************************************************************************************
Name: TrapitUtils.psm1                       Author: Brendan Furey                           Date: 05-Apr-2021

Component package in the 'Trapit - PowerShell Unit Testing Utilities' module, which facilitates unit testing
in Oracle PL/SQL following 'The Math Function Unit Testing design pattern', as described here: 

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

GitHub project for PowerShell:

    https://github.com/BrenPatF/powershell_utils

At the heart of the design pattern there is a language-specific unit testing driver function. This function
reads an input JSON scenarios file, then loops over the scenarios making calls to a function passed in as a 
parameter from the calling script. The passed function acts as a 'pure' wrapper around calls to the unit under
test. It is 'externally pure' in the sense that it is deterministic, and interacts externally only via
parameters and return value. Where the unit under test reads inputs from file the wrapper writes them based on
its parameters, and where the unit under test writes outputs to file the wrapper reads them and passes them
out in its return value. Any file writing is reverted before exit.

The driver function accumulates the output scenarios containing both expected and actual results in an object,
from which a JavaScript function writes the results in HTML and text formats.

In testing of non-JavaScript programs, the results object is written to a JSON file to be passed to the
JavaScript formatter. In Powershell, the entry-point API, Test-Format, calls Test-Unit to write the JSON file,
then calls the JavaScript formatter, format-external-file.js.

The core utility package, TrapitUtils, has three main entry point functions to facilitate the design pattern.

Write-UT_Template
-----------------
Writes a template for the unit test scenarios JSON file based on three input CSV files holding the specific
group/field structure for input and output groups, and a scenarios list. It performs the 'impure' reading and
writing parts of the process, and calls a pure function, Get-UT_TemplateObject, to do most of the logic. This
was designed with the Functional Programming idea in mind that pure functions are preferable to impure ones,
and that we should try to organise our code accordingly. In this way we can unit test the pure function more
easily, while there is little complexity in the impure one, and it may not need explicit unit testing.

Test-Format
-----------
Test-Format is the unit testing entry-point API mentioned above, and it calls Test-Unit to write the JSON
file, then calls the JavaScript formatter, format-external-file.js

Test-FormatDB
-------------
In Oracle PL/SQL, a PowerShell utility is used to automate the running of the PL/SQL function, 
Trapit_Run.Test_Output_Files to write the JSON files for a unit test group, then call the JavaScript
formatter, format-external-file.js.

The table shows the driver scripts for the relevant package: There are two examples of use, with main and test
drivers; a main script for Write-UT_Template and test script for the Get-UT_TemplateObject function; and an
install script.
==========================================================================================================
|  Script(.ps1)                       |  Package(.psm1)|  Notes                                          |
|========================================================================================================|
|  Show-HelloWorld                    |                |  Hello World program implemented as a pure      |
|  Test-HelloWorld                    |  HelloWorld    |  function to allow for unit testing as a simple |
|                                     |                |  edge case                                      |
|-------------------------------------|------------------------------------------------------------------|
|  Show-ColGroup                      |                |  File-reading and group-counting package, with  |
|  Test-ColGroup                      |  ColGroup      |  logging to file. Example of testing impure     |
|                                     |                |  units, and failing test                        |
|-------------------------------------|------------------------------------------------------------------|
|                                     |  Utils         | General utility functions (separate module)     |
|  Test-Get-UT_TemplateObject         |------------------------------------------------------------------|
|  Format-JSON-Get-UT_TemplateObject  |                |  Trapit unit testing utility functions          |
|                                     |                |                                                 |
|-------------------------------------| *TrapitUtils*  |-------------------------------------------------|
|  Install-TrapitUtils                |                |  Installer copies package to Powershell path    |
==========================================================================================================

************************************************************************************************************#>
Import-Module ($PSScriptRoot + '\..\Utils\Utils.psm1')
<#**************************************************************************************************
Write-UT_Template($stem, $delimiter): Write a template for the unit test scenarios JSON file used in
    the Math Function Unit Testing design pattern (https://github.com/BrenPatF/trapit_nodejs_tester)

    Input: $stem      - filename stem
           $delimiter - delimiter

    Return: void
                   
    Construct inp/out csv and out json file names from stem; call function to get the psobject 
    structure; convert to json and write it
**************************************************************************************************#>
function Write-UT_Template {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$stem, # filename stem
        [Parameter(Mandatory=$false)]
        [ValidateScript({
            if ($_.length -eq 1) { return $true }
            else { throw "The specified delimiter '$_' must be a single character." }
        })]
        [String]$delimiter, # delimiter
        [String]$title # title
    )

    $path = '.\' + $stem
    $csvInp = $path + '_inp.csv'
    $csvOut = $path + '_out.csv'
    $csvSce = $path + '_sce.csv'
    $json = $path + '_temp.json' 

    Get-UT_TemplateObject (Get-ObjLisFromCsv $csvInp) (Get-ObjLisFromCsv $csvOut) $delimiter $title `
                          (Get-ObjLisFromCsv $csvSce) | ConvertTo-Json -depth 4 | Set-Content $json

}
<#**************************************************************************************************

Get-UT_TemplateObject: Gets a template in object form for the unit test scenarios JSON file used in
    the Math Function Unit Testing design pattern https://github.com/BrenPatF/trapit_nodejs_tester

    Constructs object in required format from the input object lists

**************************************************************************************************#>
function Get-UT_TemplateObject([PSCustomObject[]]$inpGroupLis, # list of group, field, value objects for input
                               [PSCustomObject[]]$outGroupLis, # list of group, field, value objects for output
                               [String]$delimiter,             # delimiter
                               [String]$title,                 # title
                               [PSCustomObject[]]$sceLis) {    # list of category set, scenario, active objects

<#**************************************************************************************************

groupObjectFromLis: Takes either an input or an output list of group objects, returns meta and
    scenarios objects for the groups within outer object wrapper; special handling for empty group

**************************************************************************************************#>
    function groupObjectFromLis([PSCustomObject[]]$groupsObjLis) { # list of group, field, value objects

        function nonEmptyObject([PSCustomObject[]]$groupsObjLis) { # list of group, field, value objects

            $metaObj = New-Object -TypeName psobject
            $sceObj = New-Object -TypeName psobject
            $colLis = [string[]]$groupsObjLis[0].psobject.Properties.Name
            $seen = @{}
            $grpNames = foreach ($g in $groupsObjLis.Group) {
                if (-not $seen.ContainsKey($g)) {
                    $seen[$g] = $true
                    $g
                }
            }
            foreach ($g in $grpNames) {
                $groupObjLis = $groupsObjLis | Where {$_.group -eq $g}
                [String[]]$valArr = @()
                for($i = 2; $i -lt $colLis.length; $i++) {
                    $val = ''
                    foreach ($o in $groupObjLis) {
                        $val += $o.$($colLis[$i]) + $delimiter
                    }
                    if ($val -ne ($delimiter * ($val.Length / $delimiter.Length))) {
                        $val = $val.Substring(0, $val.Length - $delimiter.Length)
                        $valArr += $val
                    }
                }
                $fldArr = [String[]]$groupObjLis.field
                $metaObj | Add-Member -MemberType NoteProperty -Name $g -Value $fldArr
                $sceObj | Add-Member -MemberType NoteProperty -Name $g -Value $valArr
            }
            [PSCustomObject]@{
                meta = $metaObj
                sce = $sceObj
            }
        }
        If ($groupsObjLis) {
            nonEmptyObject($groupsObjLis)
        } Else {
             [PSCustomObject]@{
                meta = [PSCustomObject]@{}
                sce = [PSCustomObject]@{}
            }
        }
    }
    $inpGroupObject = groupObjectFromLis($inpGroupLis)
    $outGroupObject = groupObjectFromLis($outGroupLis)
    $metaObj = [PSCustomObject]@{
        title = $title
        delimiter = $delimiter
        inp = $inpGroupObject.meta
        out = $outGroupObject.meta
    }
    [PSCustomObject]$inp = $inpGroupObject.sce
    If ($sceLis -eq $null) {
        $sce_1Obj = [PSCustomObject]@{
            active_yn = 'Y'
            category_set = ''
            inp = $inp
            out = $outGroupObject.sce
        }
        $sceObj = [PSCustomObject]@{
            'scenario 1' = $sce_1Obj
        }
    } Else {
        $sceObj = [PSCustomObject]@{}
        Foreach ($s in $sceLis) {
            $val = [PSCustomObject]@{
                        active_yn = $s.'Active'
                        category_set = $s.'Category Set'
                        inp = $inp
                        out = $outGroupObject.sce
            }
            $sceObj | Add-Member -MemberType NoteProperty -Name $s.'scenario' -Value $val
           }
    }
    [PSCustomObject]@{
        meta = $metaObj
        scenarios = $sceObj
    }
}
<#**************************************************************************************************
Test-Unit($inpFile, $outFile, $purelyWrapUnit): Main unit testing driver function

    Input: $inpFile        - input JSON file name
           $outFile        - output JSON file name
           $purelyWrapUnit - function that takes as input an object with lists of records by group,
                             returning an object with lists of output records by group
                             
    Return: output JSON file name

    There is a simple call to a private function, main, passing the parameters received. This
    function main creates the output JSON file with the help of two functions:

        - $purelyWrapUnit is a function passed in from the client unit tester that returns an 
        object with result output groups consisting of lists of delimited strings
        - getUT_OutScenario is a local private function that takes an input scenario object and
        the output from the function above and returns the complete output scenario with groups
        containing both expected and actual result lists

    The function returns the name of the output file passed in, which is convenient for Test-Format
**************************************************************************************************#>
function Test-Unit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Leaf) { return $true }
            else { throw "The specified inpFile '$_' is not a valid file name." }
        })]
        [string]$inpFile, # input JSON file name
        [Parameter(Mandatory=$true)]
        [string]$outFile, # output JSON file name
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if ($_ -is [ScriptBlock]) { return $true }
            else { throw "The specified purelyWrapUnit '$_' is not a valid function." }
        })]
        [ScriptBlock]$purelyWrapUnit # function that takes as input an object with lists of records 
                                     # by group, returning an object with lists of output records by
                                     # group
    )
    $EXCEPTION_GRP = "Unhandled Exception"
    $outFile = $outFile -Replace '\\', '/'
    <#**************************************************************************************************

    getUT_OutScenario: Gets unit test scenario output object by merging the actuals lists for each
        group into the input object, as act, alongside the input lists, as exp

    **************************************************************************************************#>
    function getUT_OutScenario([PSCustomObject]$inpScenario, # input scenario
                               [PSCustomObject]$actObj) {    # object with lists of actuals for each output group

        $retObj = New-Object -TypeName psobject
        foreach ($o in $actObj.PSObject.Properties) {
            $grpName = $o.name
            [String[]]$exp = ($inpScenario.out.$grpName -eq $null ? @() : $inpScenario.out.$grpName)
            $value = [PSCustomObject]@{
                                        exp = $exp
                                        act = $o.value
                                      }
            $retObj | Add-Member -MemberType NoteProperty -Name $grpName -Value $value
        }

        [PSCustomObject]@{
            category_set = if ($inpScenario.category_set) {$inpScenario.category_set} else { '' }
            inp = $inpScenario.inp
            out = $retObj
        }
    }
    function callPWU([String]$delimiter, [PSCustomObject]$inp, [PSCustomObject]$out, [ScriptBlock]$purelyWrapUnit) {
        [String[]]$lineArr = @()
        try {
            [PSCustomObject]$actObj = &$purelyWrapUnit $inp
            $actObj | Add-Member -MemberType NoteProperty -Name $EXCEPTION_GRP -Value $lineArr
        } catch {
            $actObj = New-Object -TypeName psobject
            foreach ($g in $out.PSObject.Properties) {
                $actObj | Add-Member -MemberType NoteProperty -Name $g.name -Value $lineArr
            }
            [String[]]$errMsg = ($_.Exception.Message + $delimiter + $_.ScriptStackTrace)
            $actObj | Add-Member -MemberType NoteProperty -Name $EXCEPTION_GRP -Value $errMsg
        }
        $actObj
    }
    <#**************************************************************************************************

    main: Main unit testing section

        Logic:
        - read the scenarios from JSON input file into an object
        - loop over active scenarios making a 'pure' call to function purelyWrapUnit passed in
            - pass in the scenario input value
            - pass the return value, along with the input scenario, to getUT_OutScenario
            - assign the return value to scenarios object, with key as the input scenario name
        - create object with properties meta from input JSON and scenarios from the calls 
        - convert the object to JSON and write to the output json file

    **************************************************************************************************#>
    function main([String]$inpFile,               # input file
                  [String]$outFile,               # output file
                  [ScriptBlock]$purelyWrapUnit) { # function that takes scenario input value as input, returning actual output value

        [PSCustomObject]$json = Get-Content $inpFile | Out-String | ConvertFrom-Json

        $scenarios = New-Object -TypeName psobject
        foreach ($s in $json.scenarios.PSObject.Properties) {

            if ($s.value.active_yn -eq 'Y') {
                $scenarios | Add-Member -MemberType NoteProperty -Name $s.name `
                                        -Value (getUT_OutScenario $s.value (callPWU $json.meta.delimiter $s.value.inp $s.value.out $purelyWrapUnit))
            }
        }
        $out = $json.meta.out
        [String[]]$lineArr = @("Error Message", "Stack")
        $out | Add-Member -MemberType NoteProperty -Name $EXCEPTION_GRP -Value $lineArr
        $meta = [PSCustomObject]@{
            title       = $json.meta.title
            delimiter   = $json.meta.delimiter
            inp         = $json.meta.inp
            out         = $out
        }
        $outObj = [PSCustomObject]@{
            meta        = $meta
            scenarios   = $scenarios
        }
        $outObj | ConvertTo-Json -depth 6 | Set-Content $outFile
    }
    main $inpFile $outFile $purelyWrapUnit
}
<#**************************************************************************************************
Test-Format($psScript, $npmRoot): Run test driver, then call JavaScript program to format results

    Input: $utRoot         - unit test root folder
           $npmRoot        - parent folder of the JavaScript node_modules npm root folder
           $stemInpJSON    - input JSON file name stem
           $purelyWrapUnit - function that takes as input an object with lists of records by group,
                             returning an object with lists of output records by group

    Return: Results summary

    The function calls the main powershell test script, with name passed in as a parameter, then
    writes a heading line and calls the JavaScript formatter, which writes the formatted results
    files to a subfolder based on the title, and returns a summary of the results
**************************************************************************************************#>
function Test-Format {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Container) { return $true }
            else { throw "The specified utRoot '$_' is not a valid folder name." }
        })]
        [string]$utRoot, # unit test root folder
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Container) { return $true }
            else { throw "The specified npmRoot '$_' is not a valid folder name." }
        })]
        [string]$npmRoot, # parent folder of the JavaScript node_modules npm root folder
        [Parameter(Mandatory=$true)]
        [string]$stemInpJSON, # input JSON file name stem
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if ($_ -is [ScriptBlock]) { return $true }
            else { throw "The specified purelyWrapUnit '$_' is not a valid function." }
        })]
        [ScriptBlock]$purelyWrapUnit # function that takes as input an object with lists of records 
                                     # by group, returning an object with lists of output records by
                                     # group
    )
    $inpJSON = $utRoot + '\' + $stemInpJSON + '.json'
    $outJSON = $utRoot + '\' + $stemInpJSON + '_out.json'

    Test-Unit $inpJSON $outJSON $purelyWrapUnit

    $jsonFile = ($outJSON -Replace '\\', '/')
    Get-Heading ('Results summary for file: ' + $jsonFile)
    node ($npmRoot + '/node_modules/trapit/externals/format-external-file') $jsonFile
}
<#**************************************************************************************************
Test-FormatDB($unpw, $conn, $utGroup, $testRoot, $preSQL): Run Oracle unit tests for a given test group

    Input: $unpw        - Oracle user name / password string
           $conn        - Oracle connection string (such as the TNS alias)
           $utGroup     - Oracle unit test group
           $testRoot    - unit testing root folder, where results folders will be placed
           $preSQL      - SQL to execute first
                             
    Return: Results summary for each unit tested as a string

    The function runs a SQL*Plus session calling the unit test driving function, with the test group 
    passed as a parameter. The unit test driving function returns a list of the output JSON files
    created, which are then processed in a loop by the JavaScript formatter, which writes the 
    formatted results files to subfolders based on the titles, and returns a summary of the results
**************************************************************************************************#>
function Test-FormatDB {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$unpw, # Oracle user name / password string
        [Parameter(Mandatory=$true)]
        [string]$conn, # Oracle connection string (such as the TNS alias)
        [Parameter(Mandatory=$true)]
        [string]$utGroup, # Oracle unit test group
        [Parameter(Mandatory=$true)]
        [string]$testRoot, # unit testing root folder, where results folders will be placed
        [Parameter(Mandatory=$false)]
        [string]$preSQL # SQL to execute first
    )

    $sqlPlusCommands = @"
SET SERVEROUTPUT ON
DECLARE
    l_file_lis                   L1_chr_arr;
BEGIN

    l_file_lis := Trapit_Run.Test_Output_Files('GROUP');
    Utils.W('!');
    Utils.W(l_file_lis);
    Utils.W('!');

END;
/
EXIT;
"@
    $fullConn = $unpw + '@' + $conn
    if ($preSQL) {$output = $preSQL | sqlplus $fullConn}
    $output = $sqlPlusCommands -Replace 'GROUP', $utGroup | sqlplus $fullConn
    $output
    $arr = $output.Split([Environment]::NewLine)
    $ids = ($arr | select-string '!').linenumber

    if ($arr[$ids[0]] -eq '!') { throw "No output files to process..." }
    foreach($i in $ids[0] .. ($ids[1] - 2)) {
        Copy-Item $arr[$i] $testRoot
        $jsonFile = $testRoot + '/' + (Split-Path $arr[$i] -leaf)
        Get-Heading ('Results summary for file: ' + $jsonFile)
        node ($PSScriptRoot + '/node_modules/trapit/externals/format-external-file') $jsonFile
    }
}
