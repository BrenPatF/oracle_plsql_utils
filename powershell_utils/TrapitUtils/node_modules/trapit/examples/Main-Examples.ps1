$extFolders = (Get-ChildItem -Path $PSScriptRoot -Directory).name
Foreach($f in $extFolders) {
    ''
    ('Running: ' + $f + '\main-' + $f + '...')
    node ($PSScriptRoot + '\' + $f + '\main-' + $f) > ($f + '.log')
    cat ($f + '.log')
}