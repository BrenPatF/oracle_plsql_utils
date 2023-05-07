$extFolders = (Get-ChildItem -Directory).name
Foreach($f in $extFolders) {
    node ($PSScriptRoot + '\format-externals') $f > ($f + '.log')
    cat ($f + '.log')
}