Import-Module -Name $PSScriptRoot\..\PSFPLInfo -Force
# Note, this uses an incorrect username and password which is expected to throw an exception.
$testState = 0;
$badCredential = New-Object System.Management.Automation.PSCredential('incorrect@user.com',('badpassword' | ConvertTo-SecureString -asPlainText -Force)) -ErrorAction SilentlyContinue;
try
{
    $test = Authenticate $badCredential
}
catch
{
    # Exception caught, so we failed to authenticate
    $testState = 1;
}

if ($testState -ne 1)
{
    throw "FailedTest";
}
