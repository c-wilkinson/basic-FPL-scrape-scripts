Import-Module -Name $PSScriptRoot\..\PSFPLInfo -Force
$leagueTable = @();
for($gw=1; $gw -le 38; $gw++)
{
    $currentdata = $leagueTable | Where-Object {$_.TeamId -eq 1};
    $gameweek = New-Object PsObject -Property @{
                                             GameWeek = $gw;
                                             GameWeekPoints = 90;
                                             PointsOnBench = 12;
                                             TransfersMade = 0;
                                             TransfersCode = 0;
                                             OverallPoints = 90*$gw;
                                             GameWeekRank = 1;
                                          };
    if ($currentdata -ne $null)
    {
        $index = $leagueTable.IndexOf($currentdata);
        $currentdata.GameWeekHistory += $gameweek;
        $leagueTable[$index] = $currentdata;
    }
    else
    {
        $gameweekHistoryArray = @();
        $gameweekHistoryArray += $gameweek;
        $leagueTable += New-Object PsObject -Property @{
                                                         TeamValue = "£100.0";
                                                         TeamId = 1;
                                                         Manager = "Jeffrey Lebowski";
                                                         TeamName = "The Dude Abides";
                                                         GameWeekHistory = $gameweekHistoryArray;
                                                       };
    }
}

$chart = Chart $leagueTable;
$chart.SaveImage("$PSScriptRoot\Test.PNG","PNG");

if (!(Test-Path "$PSScriptRoot\Test.PNG"))
{
    throw "Failed to create chart";
}

Remove-Item "$PSScriptRoot\Test.PNG" -ErrorAction Ignore;