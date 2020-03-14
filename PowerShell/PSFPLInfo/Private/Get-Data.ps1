function Get-Data
{
<#
    .SYNOPSIS
        Common Web Scrape function.
    .DESCRIPTION
        This function takes a URL and a Web Session.
        It connects to the given URL then returns the
        contents.  We're expecting this to be JSON from
        the FPL API.
#> 
    [CmdletBinding()]
	[OutputType([object])]
    param(
        [Parameter(Mandatory=$true)][object]$session, 
        [Parameter(Mandatory=$true)][string]$url
    )
    Write-Verbose "Scraping $url";
    $json = Invoke-RestMethod -Uri $url -WebSession $session -UseBasicParsing;
    # Sleep, be as kind as possible to the FPL servers!
    Start-Sleep -Seconds 2.5;
    return $json;
}