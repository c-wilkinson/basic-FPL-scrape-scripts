param ([string]$username, [string]$password, [int]$leagueId, [string]$ssh, [string]$gituser, [string]$gitemail)
Import-Module -Name $PSScriptRoot\..\PSFPLInfo -Force
$session = Authenticate $username $password;
$league = Get-League $leagueId $session;
$chart = Chart $league;
$chart.SaveImage("Chart.png", "PNG");
cd..
New-Item -ItemType Directory -Force -Path $PSScriptRoot\..\Output;
Move-Item -Path $PSScriptRoot\Chart.png -Destination $PSScriptRoot\..\Output\Chart.png
#Git add .;
#Git config --local user.email "$gitemail";
#Git config --local user.name "$gituser";
#Git remote set-url origin git@github.com/c-wilkinson/basic-FPL-scrape-scripts;
#start-ssh-agent.cmd -quiet;
#ssh-add "$ssh";
#Git commit -m "Auto commit of new chart";
#Git push origin master;
