function IsAuthenticated
{
<#
    .SYNOPSIS
        Common Authenitcation function
    .DESCRIPTION
        This function is used to check if a 
        session is a valid authenticated FPL
        session
#> 
    [cmdletbinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)][object]$session
    )
    Write-Verbose "Check credentials";
    $authenticated = $false;
    # Test whether or not we're logged in
    $userJson = Get-Data $session (Get-URLFromAPI "me");
    if (-not ($userJson.player.id)) 
    {
        Write-Verbose "Invalid credentials";
    }
    else
    {
        Write-Verbose "Successfully authenticated on the FPL Server";
        $authenticated = $true;
    }

    return $authenticated;
}