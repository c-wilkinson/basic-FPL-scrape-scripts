function Authenticate
{
<#
    .SYNOPSIS
        Common Authenitcation function
    .DESCRIPTION
        This function is used to authenticate with the
        FPL website.  It returns a websession.
#>    
    [cmdletbinding()]
    param(
        [string]$username,
        [string]$password
    )
    $securePassword = $password | ConvertTo-SecureString -asPlainText -Force;
    $Credential = New-Object System.Management.Automation.PSCredential($username,$securePassword);	
    $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.19 Safari/537.36";
    $Uri = 'https://users.premierleague.com/accounts/login/';
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls";
    $LoginResponse = Invoke-WebRequest -Uri $Uri -SessionVariable 'session' -UseBasicParsing;
    $CsrfToken = $LoginResponse.InputFields.Where{$_.name -eq 'csrfmiddlewaretoken'}.value;
    $Response = Invoke-WebRequest -Uri $Uri -WebSession $session -Method 'Post' -UseBasicParsing -Body @{
        'csrfmiddlewaretoken' = $CsrfToken
        'login'               = $Credential.UserName
        'password'            = $Credential.GetNetworkCredential().Password
        'app'                 = 'plfpl-web'
        'redirect_uri'        = 'https://fantasy.premierleague.com/a/login'
        'user-agent'          = $UserAgent
    };
    
	if (IsAuthenticated $session)
	{
	    return $session;
	}
	else
	{
	    throw "Erorr authenticating";
	}
}