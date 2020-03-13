param ([string]$username, [string]$password, [int]$leagueId)
# This is ugly. . . will fix later
cd..
Import-Module .\PSFPLInfo.psm1
cd Tests
$session = Authenticate $username $password;
$league = Get-League $leagueId $session;
$chart = Chart $league;
$chart.SaveImage("Chart.png", "PNG");
