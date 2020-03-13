param ([string]$username, [string]$password, [int]$leagueId)
Import-Module -Name $PSScriptRoot\..\PSFPLInfo -Force
$session = Authenticate $username $password;
$league = Get-League $leagueId $session;
$chart = Chart $league;
$chart.SaveImage("Chart.png", "PNG");
cd..
Git add .;
Git commit -m "Auto commit of new chart";
Git push origin master;
