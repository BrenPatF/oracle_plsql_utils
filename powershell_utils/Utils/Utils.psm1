<#**************************************************************************************************
Name: Utils.psm1                        Author: Brendan Furey                      Date: 05-Apr-2021

Component package in the Powershell Utilities module Utils. The module has general utility functions
for pretty-printing etc.

    GitHub: https://github.com/BrenPatF/powershell_utils

There is an examples main script and a unit test script. The examples script makes calls to an
example class module that uses the pretty-printing functions, and calls other functions directly.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

====================================================================================================
| Script (.ps1)   | Module (.psm1) |  Notes                                                        |
|==================================================================================================|
|  Install-Utils  |                   Install script copies module to Powershell path              |
|-----------------|--------------------------------------------------------------------------------|
|                 |  ColGroup      |  Simple file-reading and group-counting class module          |
|  Show-Examples  |----------------|---------------------------------------------------------------|
|                 |                |                                                               |
|-----------------| *Utils*        |  General utility functions                                    |
|                 |                |                                                               |
|  Test-Utils     |----------------|---------------------------------------------------------------|
|                 |  TrapitUtils   |  Trapit unit testing utility functions                        |
====================================================================================================

Utils package with functions called by Show-Examples and Test-Utils scripts.

**************************************************************************************************#>
<#**************************************************************************************************
Write-Debug($msg, $new, $filename): Write message to the debug log file; pass $true for $new on 
    first call

    Input: $msg      - message to write
           $new      - overwrite file if $true, else append, default $false
           $filename - filename, default '.\debug.log'

    Return: void
**************************************************************************************************#>
function Write-Debug {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$msg, # message to write
        [Parameter(Mandatory=$false)]
        [bool]$new, # overwrite file if $true, else append
        [Parameter(Mandatory=$false)]
        [string]$filename = '.\debug.log' # debug log file
    )
    if ($new) {
        'Debug starting, ' + (date) + ': ' + $msg > $filename
    } else {
        $msg >> $filename
    }
}
<#**************************************************************************************************
Get-ObjLisFromCsv($csv, $delimiter): Import a CSV file with headers into an array of objects

    Input: $csv       - CSV file name
           $delimiter - delimiter, default ','

    Return: array of objects with names from the header line
**************************************************************************************************#>
function Get-ObjLisFromCsv { # delimiter
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateScript({
            if (Test-Path $_ -PathType Leaf) { return $true }
            else { throw "The specified psScript '$_' is not a valid file name." }
        })]
        [string]$csv, # CSV file
        [Parameter(Mandatory=$false)]
        [ValidateScript({
            if ($_.length -eq 1) { return $true }
            else { throw "The specified delimiter '$_' must be a single character." }
        })]
        [string]$delimiter = ',' # delimiter
    )
    $objLis = [PSObject[]]@()
    If ($csv -ne $null) {
        Import-CSV $csv -Delimiter $delimiter | %{ $objLis += $_ }
    }
    $objLis
}
<#**************************************************************************************************
Get-Heading($title, $indent): Get a heading formatted with double-underlines as 2-element list of
    strings

    Input: $title  - title (heading)
           $indent - number of space to indent, default 0

    Return: heading formatted with double-underlines as 2-element list of strings
**************************************************************************************************#>
function Get-Heading {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$title, # title
        [Parameter(Mandatory=$false)]
        [int]$indent = 0 # indent level
    )
    if ($indent -gt 0) {
        $sp = " "*$indent
    }
    "`n" + $sp + $title + "`n" + $sp + "="*("$title".length) + "`n"
}
<#**************************************************************************************************
Get-ColHeaders($header2Lis, $indent): Get column headers as 2-line string with headers underlined

    Input: $header2Lis - list of values and length/justifications objects
           $indent     - number of space to indent, default 0

    Return: column headers 2-line string with headers underlined
**************************************************************************************************#>
function Get-ColHeaders {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object[]]$header2Lis, # list of values and length/justifications objects
        [Parameter(Mandatory=$false)]
        [int]$indent = 0 # indent level
    )
    if ($indent -gt 0) {
        $sp = " "*$indent
    }
    $header2Lis | %{ 
        $l1 = $l1 + "{0,$($_[1])}  " -f $_[0]
        $l2 = $l2 + '-'*[math]::Abs($($_[1])) + "  " 
    }
    ($sp + ("$l1" -replace ".{2}$") + "`n" + $sp + "$l2".trim())
}
<#**************************************************************************************************
Get-ColHeadersLis($header2Lis, $indent): Get column headers as 2-line string with headers underlined

    Input: $header2Lis - list of values and length/justifications objects
           $indent     - number of space to indent, default 0

    Return: column headers 2-element array of strings with headers underlined
**************************************************************************************************#>
function Get-ColHeadersLis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object[]]$header2Lis, # list of values and length/justifications objects
        [Parameter(Mandatory=$false)]
        [int]$indent = 0 # indent level
    )
    if ($indent -gt 0) {
        $sp = " "*$indent
    }
    $header2Lis | %{ 
        $l1 = $l1 + "{0,$($_[1])}  " -f $_[0]
        $l2 = $l2 + '-'*[math]::Abs($($_[1])) + "  " 
    }
    @(($sp + ("$l1" -replace ".{2}$")), ($sp + "$l2".trim()))
}
<#**************************************************************************************************
Get-2LisAsLine($line2Lis, $indent): Get list of strings as one formatted line

    Input: $line2Lis - list of (string, length) pairs
           $indent   - number of space to indent, default 0

    Return: list of strings as one formatted line
**************************************************************************************************#>
function Get-2LisAsLine {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object[]]$line2Lis, # list of (string, length) pairs
        [Parameter(Mandatory=$false)]
        [int]$indent = 0 # indent level
    )
    if ($indent -gt 0) {
        $sp = " "*$indent
    }
    $l1 = ''
    $line2Lis | %{
        $l1 += "{0,$($_[1])}  " -f $_[0]
    }
    ($sp + ("$l1" -replace ".{2}$"))
}
<#**************************************************************************************************
Get-StrLisFromObjLis($objLis, $delimiter): Get list of delimited values from a list of objects;
    uses the first object to start return list with the object names delimited

    Input: $objLis    - list of objects with string-value properties
           $delimiter - delimiter, default '|'

    Return: list of name, value strings
**************************************************************************************************#>
function Get-StrLisFromObjLis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object[]]$objLis, # list of objects with string-value properties
        [Parameter(Mandatory=$false)]
        [string]$delimiter = '|' # delimiter
    )
    $strLis = @()
    $first = $true
    foreach ($obj in $objLis) {
        $valStr = ''
        foreach ($o in $obj.PSObject.Properties) {
            if ($first) {
                $hdrStr += $o.name + $delimiter
            }
            $valStr += $o.value + $delimiter
        }
        if ($first) {
            $strLis += $hdrStr -replace ".{1}$"
            $first = $false
        }
        $strLis += $valStr -replace ".{1}$"
    }
    ,$strLis
}
<#**************************************************************************************************
Remove-ExtraLF($fileName): Remove spurious new line characters from end of file written by powershell

    Input: $fileName - file name

    Return: void
**************************************************************************************************#>
function Remove-ExtraLF {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateScript({
            if (Test-Path $_ -PathType Leaf) { return $true }
            else { throw "The specified file '$_' is not a valid file name." }
        })]
        [string]$fileName # file name
    )
    $stream = [IO.File]::OpenWrite($fileName)
    $stream.SetLength($stream.Length - 2)
    $stream.Close()
    $stream.Dispose()
}
<#**************************************************************************************************
Install-Module($srcFolder, $modName): Install a module in the first folder in psmodulepath
    environment variable

    Input: $srcFolder - source folder for the module file
           $modName   - module name (stem, without '.psm1' extension)

    Return: void
**************************************************************************************************#>
function Install-Module {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Container) { return $true }
            else { throw "The specified source folder '$_' is not a valid folder name." }
        })]
        [string]$srcFolder, # source folder for the module file
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (Test-Path ($srcFolder + '\' + $_ + '.psm1') -PathType Leaf) { return $true }
            else { throw "The specified module name '$_' is not valid." }
        })]
        [string]$modName # module name
    )
    $psPathFirst = $env:psmodulepath.split(';')[0]
    "Installing $modName in $psPathFirst"
    $folder = $psPathFirst + '\' + $modName
    if (Test-Path $folder) {
        "$folder already exists"
    } else {
        New-Item -ItemType Directory -Force -Path $folder
    }
    Copy-Item -Path ($srcFolder + '\' + $modName + '.psm1') -Destination $folder -Force
}
<#**************************************************************************************************
Start-MySleep($stime, $fractionCPU): Sleep for $stime seconds, of which target $fractionCPU as
    fraction of total to be CPU

    Input: $stime       - total seconds to sleep for
           $fractionCPU - fraction of total to be CPU

    Return: void
**************************************************************************************************#>
function Start-MySleep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [float]$stime, # total seconds to sleep for
        [Parameter(Mandatory=$false)]
        [float]$fractionCPU = 0.5 # fraction of total to be CPU
    )
    [long]$startTicks = $(Get-Date).ticks
    Sleep ((1.0 - $fractionCPU) * $stime)
    $x = 1
    foreach ($i in 1..2147483647) {
        if ($(Get-Date).ticks -gt ($startTicks + 10000000 * $stime)) {break}
        $x = $x * $i
    }
}
# Not yet tested and documented...
function Find-InFiles ($fileExpr, $searchStr, $tp = "L"){
    switch ($tp) {
        "L" { Get-ChildItem -Recurse $fileExpr | Select-String $searchStr | Select-Object -Unique Path | Split-Path -Leaf }
        "P" { Get-ChildItem -Recurse $fileExpr | Select-String $searchStr | Select-Object -Unique Path | Split-Path -Leaf }
        "S" { Get-ChildItem -Recurse $fileExpr | Select-String $searchStr }
    }
}
function Find-InFilesArray ([string[]]$strLis, [string]$ext, [string]$root){
    "Searching $root for: $($strLis -join ',')"
    $counts = [ordered]@{}
    foreach($s in $strLis) {
        [string[]]$filesFoundLis = @((Find-InFiles -fileExpr ("*." + $ext) -searchStr "$s" -tp "P" -Path $root).Path)
        $counts[$s] = $filesFoundLis.length
        if($s -eq $strLis[0]) {
            $filesLis = $filesFoundLis
        } else {
            $filesLis = $filesLis | Where-Object {$filesFoundLis -contains $_}
        }
    }
    heading "All search strings were found in the following $($filesLis.length) files..."
    $filesLis -Replace [Regex]::Escape($root), ''
    heading "File counts by individual search string..."
    $counts
}
