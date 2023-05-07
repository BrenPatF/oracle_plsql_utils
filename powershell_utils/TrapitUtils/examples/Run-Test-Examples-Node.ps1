Import-Module Utils
$utDir = $PSScriptRoot -Replace '\\', '/'
$npmDir = $utDir + '/../node_modules/trapit/'
('UT folder: ' + $utDir)
('JavaScript folder: ' + $npmDir)
$utOutFiles = @('helloworld/helloworld_out.json', 'colgroup/colgroup_out.json')

'Executing:  Test-HelloWorld.ps1 at ' + (Date -format "dd-MMM-yy HH:mm:ss")
($utDir + '/helloworld/Test-HelloWorld')
'Executing:  Test-ColGroup.ps1'
($utDir + '/colgroup/Test-ColGroup')

Foreach($f in $utOutFiles) {
    $jsonFile = ($utDir + '/' + $f)
    $log = $utDir + "/" + $f.split("/")[0] + ".log"
    node ($npmDir + '/externals/format-external-file') $jsonFile > $log
    Get-Heading ('Results summary for file: ' + $jsonFile)
    cat $log
}