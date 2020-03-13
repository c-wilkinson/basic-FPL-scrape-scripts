function EncodeString
{
<#
    .SYNOPSIS
        String encoding function
    .DESCRIPTION
        This function encodes a string to ensure that 
        non-latin based characters are returned correctly.
#> 
    [CmdletBinding()]
    param(
        [string]$string
    )
    # Encoding, ugly fix for bug #6
    $utf8 = [System.Text.Encoding]::GetEncoding(65001);
    $iso88591 = [System.Text.Encoding]::GetEncoding(28591);
    $stringBytes = $utf8.GetBytes($string);
    $stringEncoded = [System.Text.Encoding]::Convert($utf8,$iso88591,$stringBytes);
    $newString = $utf8.GetString($stringEncoded);
    return $newString;
}