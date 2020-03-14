function Get-URLFromAPI
{
<#
    .SYNOPSIS
        Gets specified API URL
    .DESCRIPTION
        This function is to allow me to have a single
        location for updating URLs if required
#> 
    [CmdletBinding()]
	[OutputType([string])]
    param(
        [Parameter(Mandatory=$true)][string]$api,
        [Parameter(Mandatory=$false)][string]$arg1,
        [Parameter(Mandatory=$false)][string]$arg2
    )
    Write-Verbose "Get URL from API $api";
    $url = switch ($api) {
                           "me"  {"https://fantasy.premierleague.com/api/me/"; break}
                           "usersLogin"   {"https://users.premierleague.com/accounts/login/"; break}
                           "login" {"https://fantasy.premierleague.com/a/login"; break}
                           "classic"  {"https://fantasy.premierleague.com/api/leagues-classic/$arg1/standings/?page_standings=$arg2"; break}
                           "team" {"https://fantasy.premierleague.com/api/entry/$arg1/history/"; break}
                           # If we hit this, something has gone wrong
                           default {"https://www.craigwilkinson.dev"; break}
                         };

    return $url;
}