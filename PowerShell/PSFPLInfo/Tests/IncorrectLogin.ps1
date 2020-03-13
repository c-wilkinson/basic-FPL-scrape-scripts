Import-Module -Name $PSScriptRoot\..\PSFPLInfo -Force
# Note, this uses an incorrect username and password which is expected to throw an exception.
$testState = 0;
try
{
    $test = Authenticate incorrect@user.com badpassword
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
