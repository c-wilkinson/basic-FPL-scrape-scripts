param ([PSCredential]$credential, [int]$leagueId)
Import-Module -Name $PSScriptRoot\..\PSFPLInfo -Force
# Note, this uses a correct username and password which is expected to not throw an exception.
$testState = 0;
try
{
    $test = Authenticate $credential;
}
catch
{
    # Exception caught, so we failed to authenticate
    throw "FailedTest";
}
