$extFolders = (Get-ChildItem -Path $PSScriptRoot -Directory).name
Foreach($f in $extFolders) {
    ''
    ('Running: ' + $f + '\main-' + $f + '...')
    node ($PSScriptRoot + '\' + $f + '\main-' + $f) > ('main-' + $f + '.log')
    cat ('main-' + $f + '.log')
}