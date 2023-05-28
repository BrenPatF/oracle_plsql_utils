<#**************************************************************************************************
Name: TrapitUtils.psm1                      Author: Brendan Furey                  Date: 05-Apr-2021

Component module in the 'Trapit Utils' project in the powershell repository 'Powershell Utilities'.
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
|  Test-ColGroup                   |  ColGroup     | module, with logging to file. Example of      |
|  Run-Test-ColGroup               |               | testing impure units, and error display       |
|----------------------------------|---------------|-----------------------------------------------|
|                                  |  Utils        | General utility functions                     |
|  Test-Get-UT_TemplateObject      |---------------|-----------------------------------------------|
|  Run-Test-Get-UT_TemplateObject  |               | Trapit unit testing utility functions         |
|----------------------------------| *TrapitUtils* |-----------------------------------------------|
|  Install-TrapitUtils             |               | Installer copies module to Powershell path    |
====================================================================================================
This file contains the TrapitUtils module for unit testing following the Math Function Unit Testing
design pattern.
**************************************************************************************************#>
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
        [string]$delimiter # delimiter
    )

    $path = '.\' + $stem
    $csvInp = $path + '_inp.csv'
    $csvOut = $path + '_out.csv'
    $csvSce = $path + '_sce.csv'
    $json = $path + '_temp.json' 

    Get-UT_TemplateObject (Get-ObjLisFromCsv $csvInp) (Get-ObjLisFromCsv $csvOut) $delimiter `
                          (Get-ObjLisFromCsv $csvSce) | ConvertTo-Json -depth 4 | Set-Content $json

}
<#**************************************************************************************************

Get-UT_TemplateObject: Gets a template in object form for the unit test scenarios JSON file used in
    the Math Function Unit Testing design pattern https://github.com/BrenPatF/trapit_nodejs_tester

    Constructs object in required format from the input object lists

**************************************************************************************************#>
function Get-UT_TemplateObject($inpGroupLis, # list of group, field, value triples for input
                               $outGroupLis, # list of group, field, value triples for output
                               $delimiter,   # delimiter
                               $sceLis) {    # list of category set, scenario, active triples

<#**************************************************************************************************

groupObjectFromLis: Takes either an input or an output group, returns meta and scenarios objects for
    the group within outer object wrapper; special handling for empty group

**************************************************************************************************#>
    function groupObjectFromLis($groupLis) { # list of group, field, value triples

        function nonEmptyObject($groupLis) { # list of group, field, value triples

            $metaObj = New-Object -TypeName psobject
            $sceObj = New-Object -TypeName psobject

            $grpNames = @{}
            foreach ($g in $groupLis) {
                If ($grpNames[$g.group]) {
                    Continue
                } Else { 
                    $grpNames.Add($g.group, 1)
                    $flds = $groupLis | Where {$_.group -eq $g.group}
                    $val = ''
                    foreach ($f in $flds) {
                        $val += $f.value + $delimiter
                    }
                    $fldArr = [String[]]$flds.field

                    $valArr = [String[]]($val -Replace ("." * $delimiter.length + "$"))
                    $metaObj | Add-Member -MemberType NoteProperty -Name $g.group -Value $fldArr
                    $sceObj | Add-Member -MemberType NoteProperty -Name $g.group -Value $valArr
                }
            }
            @{
                meta = $metaObj
                sce = $sceObj
            }
        }
        If ($groupLis) {
            nonEmptyObject($groupLis)
        } Else {
            @{
                meta = [PSCustomObject]@{}
                sce = [PSCustomObject]@{}
            }
        }
    }
    $inpGroupObject = groupObjectFromLis($inpGroupLis)
    $outGroupObject = groupObjectFromLis($outGroupLis)
    $metaObj = [PSCustomObject]@{
        title = 'title'
        delimiter = $delimiter
        inp = $inpGroupObject.meta
        out = $outGroupObject.meta
    }
    $inp = $inpGroupObject.sce
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
            if ($_ -is [scriptblock]) { return $true }
            else { throw "The specified purelyWrapUnit '$_' is not a valid function." }
        })]
        [scriptblock]$purelyWrapUnit # function that takes as input an object with lists of records 
                                     # by group, returning an object with lists of output records by
                                     # group
    )
    $EXCEPTION_GRP = "Unhandled Exception"
    $outFile = $outFile -Replace '\\', '/'
    <#**************************************************************************************************

    getUT_OutScenario: Gets unit test scenario output object by merging the actuals lists for each
        group into the input object, as act, alongside the input lists, as exp

    **************************************************************************************************#>
    function getUT_OutScenario($inpScenario, # input scenario
                               $actObj) {    # object with lists of actuals for each output group

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
    function callPWU($delimiter, $inp, $out, $purelyWrapUnit) {
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
    function main($inpFile,          # input file
                  $outFile,          # output file
                  $purelyWrapUnit) { # function that takes scenario input value as input, returning actual output value

        $json = Get-Content $inpFile | Out-String | ConvertFrom-Json

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
    $outFile
}
<#**************************************************************************************************
Test-Format($psScript, $npmRoot): Run test driver, then call JavaScript program to format results

    Input: $psScript - full name of the powershell unit test driver script
           $npmRoot  - parent folder of the JavaScript node_modules npm root folder
                             
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
            if (Test-Path $_ -PathType Leaf) { return $true }
            else { throw "The specified psScript '$_' is not a valid file name." }
        })]
        [string]$psScript, # full name of the powershell unit test driver script
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Container) { return $true }
            else { throw "The specified npmRoot '$_' is not a valid folder name." }
        })]
        [string]$npmRoot # parent folder of the JavaScript node_modules npm root folder
    )
    $jsonFile = (& ($psScript -Replace '\\', '/'))
    Get-Heading ('Results summary for file: ' + $jsonFile)
    node ($npmRoot + '/node_modules/trapit/externals/format-external-file') $jsonFile
}
<#**************************************************************************************************
Test-FormatFolder($psScriptLis, $jsonFolder, $npmRoot): Run a list of test drivers, then call 
    JavaScript program to format results

    Input: $psScriptLis - array of full names of the unit test driver scripts
           $jsonFolder  - folder where JSON files are copied, and results subfolders placed
           $npmRoot     - parent folder of the JavaScript node_modules npm root folder
                             
    Return: Results summary

    The function runs a loop over the input array of test scripts, calling the script and copying
    the output JSON to the folder passed in. After the loop, calls the folder version of the 
    JavaScript formatter, which writes the formatted results files to subfolders based on the
    titles, and returns a summary of the results
**************************************************************************************************#>
function Test-FormatFolder { 
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$psScriptLis, # array of full names of the unit test driver scripts
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Container) { return $true }
            else { throw "The specified jsonFolder '$_' is not a valid folder name." }
        })]
        [string]$jsonFolder, # folder where JSON files are copied, and results subfolders placed
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Container) { return $true }
            else { throw "The specified npmRoot '$_' is not a valid file name." }
        })]
        [string]$npmRoot # path to the folder holding node_modules JavaScript npm root
    )
    foreach ($s in $psScriptLis) {
        $jsonFile = & $s
        Copy-Item $jsonFile $jsonFolder
    }
    node ($npmRoot + '/node_modules/trapit/externals/format-external-folder') ($jsonFolder -Replace '\\', '/')
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
        $fileName = $testRoot + '/' + (Split-Path $arr[$i] -leaf)
        ' '
        node ($PSScriptRoot + '/node_modules/trapit/externals/format-external-file') $fileName
    }
}
