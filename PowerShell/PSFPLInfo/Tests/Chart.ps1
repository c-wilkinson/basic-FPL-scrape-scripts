param ([string]$username, [string]$password, [int]$leagueId)
Import-Module -Name $PSScriptRoot\..\PSFPLInfo -Force
$session = Authenticate $username $password;
$league = Get-League $leagueId $session;
$chart = Chart $league;
$chart.SaveImage("Chart.png", "PNG");
New-Item -ItemType Directory -Force -Path "$PSScriptRoot\..\Output";
Move-Item -Path "$PSScriptRoot\Chart.png" -Destination "$PSScriptRoot\..\Output\Chart.png";
