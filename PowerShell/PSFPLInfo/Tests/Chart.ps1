param ([string]$username, [string]$password, [int]$leagueId)
Install-Module -Name PSFPLInfo
Import-Module -Name PSFPLInfo
cd Tests
$session = Authenticate $username $password;
$league = Get-League $leagueId $session;
$chart = Chart $league;
$chart.SaveImage("Chart.png", "PNG");
