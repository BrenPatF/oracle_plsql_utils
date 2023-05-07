Import-Module Utils
foreach ($i in 1..100) {

    $fields_comma += 'Field' + $i + ','
    $values_comma += 'Value' + $i + ','
    $fields_pipe += 'Field' + $i + '|'
    $values_pipe += 'Value' + $i + '|'
    $hdrs += ('                                                                                          "hdr' + $i + ";5`",`n")
    $flds += ('                                                                                          "fld' + $i + ";5`",`n")
    $debug += ('                                                                                          "Line ' + $i + "...;;`",`n")
}
$fields_comma = $fields_comma -replace ".$"
$values_comma = $values_comma -replace ".$"
$fields_pipe  = $fields_pipe -replace ".$"
$values_pipe  = $values_pipe -replace ".$"
foreach ($i in 1..100) {
    $valLis_comma += '                                                                               "' + $i + '-' + $values_comma + "`",`n"
    $valLis_pipe += '                                                                               "' + $i + '-' + $values_pipe + "`",`n"
}

Get-Heading 'Write-Debug - 100x3'
$debug

Get-Heading 'Get-ObjLisFromCsv - 101x100'
Get-Heading '1 Fields row - 1x100' 10
$fields_comma
Get-Heading '100 Values rows - 100x100' 10
$valLis_comma

Get-Heading 'Get-ColHeaders - 100x2'
$hdrs

Get-Heading 'Get-2LisAsLine - 100x2'
$flds

Get-Heading 'Get-StrLisFromObjLis - 101x100'
Get-Heading '1 Fields row - 1x100' 10
$fields_pipe
Get-Heading '100 Values rows - 100x100' 10
$valLis_pipe
