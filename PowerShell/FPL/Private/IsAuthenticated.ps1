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
    param(
        [object]$session
    )
    $authenticated = $false;
    # Test whether or not we're logged in
    $userJson = Get-Data $session "https://fantasy.premierleague.com/api/me/";
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