$extFolders = (Get-ChildItem -Path $PSScriptRoot -Directory).name
Foreach($f in $extFolders) {
    ''
    ('Running: ' + $f + '\test-' + $f + '...')
    node ($PSScriptRoot + '\' + $f + '\test-' + $f) > ('test-' + $f + '.log')
    cat ('test-' + $f + '.log')
}