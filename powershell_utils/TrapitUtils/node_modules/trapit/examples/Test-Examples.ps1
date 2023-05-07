$extFolders = (Get-ChildItem -Path $PSScriptRoot -Directory).name
Foreach($f in $extFolders) {
    ''
    ('Running: ' + $f + '\test-' + $f + '...')
    node ($PSScriptRoot + '\' + $f + '\test-' + $f) > ($f + '.log')
    cat ($f + '.log')
}