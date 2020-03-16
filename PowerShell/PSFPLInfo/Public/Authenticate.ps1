function Authenticate
{
<#
    .SYNOPSIS
        Common Authenitcation function
    .DESCRIPTION
        This function is used to authenticate with the
        FPL website.  It returns a websession.
    .PARAMETER credential
        This a PSCredential object containing the username and password
        used to login to the FPL server.
    .OUTPUTS
        System.Object.  Authenticate returns a websession if the passed in 
        PSCredential was able to successfully authenticate against the 
        FPL server.
    .EXAMPLE
        C:\> $session = Authenticate -credential $credential;
    .EXAMPLE
        C:\> $session = Authenticate -credential (New-Object System.Management.Automation.PSCredential('some@e-mail.com', ('somePassword' | ConvertTo-SecureString -asPlainText -Force)));
    .EXAMPLE
        C:\> $session = Authenticate $credential;
    .EXAMPLE
        C:\> $session = Authenticate (New-Object System.Management.Automation.PSCredential('some@e-mail.com',('somePassword' | ConvertTo-SecureString -asPlainText -Force)));
#>    
    [cmdletbinding()]
	[OutputType([object])]
    param(
        [Parameter(Mandatory=$true)][PSCredential]$credential
    )
    Write-Verbose "Attempt to authenticate with FPL servers";
    $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.19 Safari/537.36";
    $Uri = (Get-URLFromAPI "usersLogin");
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls";
    $LoginResponse = Invoke-WebRequest -Uri $Uri -SessionVariable 'session' -UseBasicParsing;
    $CsrfToken = $LoginResponse.InputFields.Where{$_.name -eq 'csrfmiddlewaretoken'}.value;
    $Response = Invoke-WebRequest -Uri $Uri -WebSession $session -Method 'Post' -UseBasicParsing -Body @{
        'csrfmiddlewaretoken' = $CsrfToken
        'login'               = $credential.UserName
        'password'            = $credential.GetNetworkCredential().Password
        'app'                 = 'plfpl-web'
        'redirect_uri'        = (Get-URLFromAPI "login")
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