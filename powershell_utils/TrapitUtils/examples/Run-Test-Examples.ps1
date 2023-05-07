Import-Module TrapitUtils
$psScriptLis = @(($PSScriptRoot + '/colgroup/Test-ColGroup.ps1'), `
                 ($PSScriptRoot + '/helloworld/Test-HelloWorld.ps1'))
$jsonFolder  = $PSScriptRoot + '/results'
$npmRoot     = $PSScriptRoot + '/..'
Test-FormatFolder $psScriptLis $jsonFolder $npmRoot