<#**************************************************************************************************
Name: OracleUtils.psm1                  Author: Brendan Furey                      Date: 03-Jan-2025

Component package in the Powershell Oracle Utility module OracleUtils. The module has a utility that
facilitates installation of an Oracle database module comprising components such as tables, views,
packages etc. by means of a set of SQL*Plus scripts. These scripts have to be created separately for
the particular Oracle module, while the Powershell utility coordinates their execution. The utility
also allows for copying of files to a folder, such as a folder used for data loading via external
tables.

    GitHub: https://github.com/BrenPatF/powershell_utils

As well as the module file, there is an install script, an example script, and a unit test script.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

It uses unit testing utility functions from the separate Powershell module, TrapitUtils.

====================================================================================================
| Script (.ps1)           | Module (.psm1) |  Notes                                                |
|==================================================================================================|
|  Install-OracleUtils    |     Installer copies module to Powershell path                         |
|-------------------------|------------------------------------------------------------------------|
|  Install-Utils          |     Example script installs Oracle PL/SQL General Utilities Module     |
|                         |------------------------------------------------------------------------|
|-------------------------| *OracleUtils*  |  Powershell Oracle utility functions                  |
|                         |----------------|-------------------------------------------------------|
|                         |  TrapitUtils   |  Trapit unit testing utility functions                |
|                         |------------------------------------------------------------------------|
|  Test-InstallOracleApp  |     Unit test script                                                   |
====================================================================================================

OracleUtils package with entry point functions called by example and unit test scripts.

**************************************************************************************************#>
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '..\Utils\Utils.psm1')
$nl = [Environment]::NewLine
$TNS_ALIAS = '@orclpdb'
<#**************************************************************************************************
copyDataFilesInput($inputPath, $fileLis): 

    Input: $inputPath - path for Oracle directory
           $fileLis   - list of files to copy to above path

    Return: Logging message
**************************************************************************************************#>
function copyDataFilesInput($fileCopies, $testMode) {

    $inputPath, $fileLis = $fileCopies.inputPath, $fileCopies.fileLis
    $copiedLis = @()
    if (Test-Path $inputPath) {
        $folderExists = 'Y'
        $msg = "The item $inputPath is a folder, copy there..."
    } else {
        $folderExists = 'N'
        $msg = "The item $inputPath does not exist, creating folder..."
        if(-Not $testMode) {
            $msg += ($nl + (New-Item -ItemType Directory -Force -Path $inputPath))
        }
    }
    foreach($f in $fileLis) {
        if(-Not $testMode) {Copy-Item $f $inputPath}
        $msg += ($nl + "Copy $f to $inputPath")
        $copiedLis += $f
    }
    [PSCustomObject]@{folder = $inputPath; folderExists = $folderExists; fileLis = $copiedLis}
}
function valParams ($fileCopies, $sqlInstalls) {
    if($fileCopies) {
        $inputPath = $fileCopies.inputPath
        $fileLis = $fileCopies.fileLis
        if($fileLis.length -eq 0) {
            if($inputPath -ne '') {
                throw "If input path ($inputPath) present, there must be at least one file to copy."
            }
        } elseif($inputPath -eq '') {
            throw "If there is a file to copy input path must be specified."
        }
        # Validate that $inputPath is not a file
        if (Test-Path -PathType Leaf $inputPath) {
            throw "The item $inputPath is a file, aborting..."
        }
        # Validate that each file in $fileLis exists
        foreach ($file in $fileLis) {
            if (-not (Test-Path -Path $file -PathType Leaf)) {
                throw "The specified file '$file' does not exist."
            }
        }
    }
    if($sqlInstalls) {
        $requiredKeys = @('folder', 'script', 'schema', 'prmLis')
    
        # Validate that each hashtable contains all required properties
        foreach ($install in $sqlInstalls) {
            foreach ($key in $requiredKeys) {
                if (-not $install.ContainsKey($key)) {
                    throw "Missing required key '$key' in hashtable, actual keys: $($install.keys | Sort-Object)"
                }
            }
            if ($install.folder -eq '') {
                throw "SQL folder required."
            } elseif (-not (Test-Path -Path $install.folder -PathType Container)) {
                throw "The specified folder '$($install.folder)' does not exist."
            }
            $fullFile = $install.folder + '/' + $install.script
            if ($install.script -eq '') {
                throw "SQL script name required."
            } elseif (-not (Test-Path -Path $fullFile -PathType Leaf)) {
                throw "The specified script '$fullFile' does not exist."
            }
            if ($install.schema -eq '') {
                throw "SQL schema name required."
            }
        }
    }
}
function installApp ($root, $installs, $testMode) {
    $actions = @()
    Foreach($i in $installs){
        sl ($root + '/' + $i.folder)
        $script = '@' + $i.script
        $sysdba = ''
        if ($i.schema -eq 'sys') {
            $sysdba = ' AS SYSDBA'
        }
        $conn = $i.schema + '/' + $i.schema + $TNS_ALIAS + $sysdba
        $par1, $par2, $par3 = '', '', ''
        if($i.prmLis -ne $null) {
            $par1 = $i.prmLis[0]
            if($i.prmLis.length -gt 1) {
                $par2 = $i.prmLis[1]
                if($i.prmLis.length -gt 2) {
                    $par3 = $i.prmLis[2]
                }
            }
        }
        if(-Not $testMode) {
            & sqlplus $conn $script $par1 $par2 $par3 > $null
        }
        $actions += [PSCustomObject]@{subFolder = $i.folder; exeStr = "sqlplus $conn $script $par1 $par2 $par3".TrimEnd()}

    }
    sl $root
    $actions
}
<#**************************************************************************************************
Install-OracleApp($fileCopies, $sqlInstalls, $testMode): 

    Input:
        [PSCustomObject]$fileCopies - object with fields:
            [string]inputPath - folder to which to copy the files
            [string[]]fileLis - list of files to copy

        [PSCustomObject[]]$sqlInstalls - array of objects with fields:
            [string]folder   - SQL script folder
            [string]script   - SQL script name
            [string]schema   - SQL script schema name
            [string[]]prmLis - array of parameters to pass to SQL script

        [bool]$testMode - if true, executes the file copying and SQL*Plus steps specified in the 
                          other parameters, else only logs the steps that would be taken

Return value:
        [PSCustomObject] - object with fields:
            [PSCustomObject]fileCopy - object with fields:
                [string]folder       - folder to which to copy the files
                [string]folderExists - Y/N flag, Y if folder exists already
                [string[]]fileLis    - list of files to copy
            [PSCustomObject[]]appLis - array of objects with fields:
                [string]subFolder    - SQL script subfolder
                [string]exeStr       - SQL script execution string

**************************************************************************************************#>
function Install-OracleApp {
    param (
        [Parameter(Mandatory = $false)]
        [PSCustomObject]$fileCopies,
        [Parameter(Mandatory = $false)]
        [PSCustomObject[]]$sqlInstalls,
        [Parameter(Mandatory = $false)]
        [bool]$testMode = $false
    )
    ValParams -fileCopies $fileCopies -sqlInstalls $sqlInstalls
    if($fileCopies) {
        $copyRet = copyDataFilesInput $fileCopies $testMode
    }
    if($sqlInstalls) {
        $root = $($MyInvocation.PSScriptRoot)
        $appRet = installApp $root $sqlInstalls $testMode
    }
    [PSCustomObject]@{fileCopy = $copyRet; appLis = $appRet}
}
<#**************************************************************************************************
Write-OracleApp ($result)

    Input:
        [PSCustomObject]$result - object with fields:
            [PSCustomObject]fileCopy - object with fields:
                [string]folder       - folder to which to copy the files
                [string]folderExists - Y/N flag, Y if folder exists already
                [string[]]fileLis    - list of files to copy
            [PSCustomObject[]]appLis - array of objects with fields:
                [string]subFolder    - SQL script subfolder
                [string]exeStr       - SQL script execution string

**************************************************************************************************#>
function Write-OracleApp ($result) {
    Get-Heading "Copy folder"
    $fc = $result.fileCopy
    ("Copy folder = " + $fc.folder + ", existing = " + $fc.folderExists)
    Get-Heading "Files copied..."
    $maxLenFile = ($fc.fileLis | measure-object -property length -maximum).maximum
    Get-ColHeaders @(,@('File', -$maxLenFile))
    foreach($f in $fc.fileLis) {$f}
    Get-Heading "Sqlplus results"
    $maxLenSubFolder = ($result.appLis.subFolder | measure-object -property length -maximum).maximum
    $maxLenExeStr = ($result.appLis.exeStr | measure-object -property length -maximum).maximum
    ((Get-ColHeaders @(@('subFolder', -$maxLenSubFolder), @('exeStr', -$maxLenExeStr))))
    foreach($a in $result.appLis) {
        ((Get-2LisAsLine @(@($a.subFolder, -$maxLenSubFolder), @($a.exeStr, -$maxLenExeStr))))
    }
}
Export-ModuleMember -Function Install-OracleApp, Write-OracleApp