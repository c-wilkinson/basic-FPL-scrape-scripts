function Get-League
{
<#
    .SYNOPSIS
        Create correct league structure
    .DESCRIPTION
        This function makes a structure where the team is the
        key and the gameweek list object is the value
#> 
    [CmdletBinding()]
	[OutputType([object])]
    param(
        [Parameter(Mandatory=$true)][int]$leagueId,
        [Parameter(Mandatory=$true)][object]$session
    )
    Write-Verbose "Attempt to build a structure of the specific mini-league";
    $structure = CreateInitialLeagueStructure $leagueId $session;
    $leagueTable = @();
    foreach($info in $structure)
    {
        if ($info.Manager)
        {
            $currentdata = $leagueTable | Where-Object {$_.TeamId -eq $info.TeamId};
            $gameweek = New-Object PsObject -Property @{
                                                         GameWeek = $info.GameWeek;
                                                         GameWeekPoints = $info.GameWeekPoints;
                                                         PointsOnBench = $info.PointsOnBench;
                                                         TransfersMade = $info.TransfersMade;
                                                         TransfersCode = $info.TransfersCode;
                                                         OverallPoints = $info.OverallPoints;
                                                         GameWeekRank = $info.GameWeekRank;
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
                                                                 TeamValue = $info.TeamValue;
                                                                 TeamId = $info.TeamId;
                                                                 Manager = $info.Manager;
                                                                 TeamName = $info.TeamName;
                                                                 GameWeekHistory = $gameweekHistoryArray;
                                                               };
            }
        }
    }

    return $leagueTable;
}