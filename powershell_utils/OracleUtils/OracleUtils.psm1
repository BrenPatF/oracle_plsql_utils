<#**************************************************************************************************
Name: OracleUtils.psm1                  Author: Brendan Furey                      Date: 13-Oct-2024

Powershell module with utility code for Oracle database installation

**************************************************************************************************#>
$nl = [Environment]::NewLine
<#**************************************************************************************************
copyDataFilesInput($inputPath, $fileLis): 

    Input: $inputPath - path for Oracle directory
           $fileLis   - list of files to copy to above path

    Return: Logging message
**************************************************************************************************#>
function copyDataFilesInput($inputPath, $fileLis) {
    if (Test-Path $inputPath) {
        $msg = "The item $inputPath is a folder, copy there..."
    } else {
        $msg = "The item $inputPath does not exist, creating folder..."
        $msg += ($nl + (New-Item -ItemType Directory -Force -Path $inputPath))
    }
    foreach($f in $fileLis) {
        Copy-Item $f $inputPath
        $msg += ($nl + "Copied $f to $inputPath")
    }
    $msg
}

<#**************************************************************************************************
Install-OracleApp($inputPath, $fileLis, $installs): 

    Input: $inputPath - path for Oracle directory
           $fileLis   - list of files to copy to above path
           $installs  - list of install objects, with fields:
                            folder - folder for SQL script
                            script - SQL script name (stem)
                            schema - schema to run SQL script in
                            prmLis - list of parameters to pass to SQL script

    Return: Logging messages
**************************************************************************************************#>
function Install-OracleApp {
    param (
        [Parameter(Mandatory = $true)]
        [string]$inputPath,
        [Parameter(Mandatory = $true)]
        [string[]]$fileLis,
        [Parameter(Mandatory = $true)]
        [PSCustomObject[]]$installs
    )
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
    $requiredKeys = @('folder', 'script', 'schema', 'prmLis')

    # Validate that each hashtable contains all required properties
    foreach ($install in $installs) {
        foreach ($key in $requiredKeys) {
            if (-not $install.ContainsKey($key)) {
                throw "Missing required key '$key' in hashtable: $install"
            }
        }
        if (-not (Test-Path -Path $install.folder -PathType Container)) {
            throw "The specified folder '$($install.folder)' does not exist."
        }
        $fullFile = $install.folder + '/' + $install.script + '.sql'
        if (-not (Test-Path -Path $fullFile -PathType Leaf)) {
            throw "The specified script '$fullFile' does not exist."
        }
    }

    Date -format "dd-MMM-yy HH:mm:ss"
    "First try to copy files to input folder..."
    copyDataFilesInput $inputPath $fileLis
    $installs
    $root = $($MyInvocation.PSScriptRoot)
    Foreach($i in $installs){
        sl ($root + '/' + $i.folder)
        $script = '@./' + $i.script
        $sysdba = ''
        if ($i.schema -eq 'sys') {
            $sysdba = ' AS SYSDBA'
        }
        $conn = $i.schema + '/' + $i.schema + '@orclpdb' + $sysdba
        'Executing: ' + $script + ' for connection ' + $conn
        if($i.prmLis -ne $null) {
            $par1 = $i.prmLis[0]
            if($i.prmLis.length -gt 1) {
                $par2 = $i.prmLis[1]
                if($i.prmLis.length -gt 2) {
                    $par3 = $i.prmLis[2]
                } else {
                    $par3 = ''
                }
            } else {
                $par2 = ''
            }
        } else {
            $par1 = ''
        }
        & sqlplus $conn $script $par1 $par2 $par3
    }
    sl $root
}
Export-ModuleMember -Function Install-OracleApp