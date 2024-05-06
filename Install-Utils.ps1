#$PSStyle.OutputRendering = 'PlainText'
#$Errorview = "NormalView"
Date -format "dd-MMM-yy HH:mm:ss"
"First try to copy files to input folder..."
. ./Copy-DataFilesInput
if (-not $IsFolder) {
    "Could not copy files, so aborting main script..."
    exit
}
# uncomment first element to have schema dropped and re-created
$installs = @(#@{folder = '.'; script = 'drop_utils_users'; schema = 'sys'},
              @{folder = '.'; script = 'install_sys'; schema = 'sys'},
              @{folder = 'lib'; script = 'install_utils'; schema = 'lib'},
              @{folder = 'install_ut_prereq\lib'; script = 'install_lib_all'; schema = 'lib'},
              @{folder = 'install_ut_prereq\app'; script = 'c_syns_all'; schema = 'app'},
              @{folder = 'lib'; script = 'install_utils_tt'; schema = 'lib'},
              @{folder = 'app'; script = 'install_col_group'; schema = 'app'})
$installs

Foreach($i in $installs){
    sl ($PSScriptRoot + '/' + $i.folder)
    $script = '@./' + $i.script
    $sysdba = ''
    if ($i.schema -eq 'sys') {
        $sysdba = ' AS SYSDBA'
    }
    $conn = $i.schema + '/' + $i.schema + '@orclpdb' + $sysdba
    'Executing: ' + $script + ' for connection ' + $conn
    if ($i.script -eq 'install_utils') {
        $schema = 'app'
    } elseif ($i.script -eq 'c_syns_all' -or $i.script -eq 'install_col_group') {
        $schema = 'lib'
    } else {
        $schema = ''
    }
    & sqlplus $conn $script $schema
}
sl $PSScriptRoot
