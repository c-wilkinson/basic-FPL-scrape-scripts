function CreateInitialLeagueStructure
{
<#
    .SYNOPSIS
        Create Initial League Structure
    .DESCRIPTION
        This function takes an object which is parsed 
        into the initial league structure.
#> 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][int]$leagueId,
        [Parameter(Mandatory=$true)][object]$session
    )
    Write-Verbose "Create the initial league structure object";
    $allleagueTablePage = @();
    $pageNumber = 1;
    $loop = $true;
    while ($loop)
    {    
        $leagueTableJson = Get-Data $session (API-URL "classic" "$leagueId" "$pageNumber");
        $allleagueTablePage += $leagueTableJson;
        $loop = $leagueTableJson.standings.has_next;
        $pageNumber++;
    }
    
    $unstructured = @();
    foreach($json in $allleagueTablePage)
    {
        foreach($leaguePage in $json.standings)
        {
            foreach($team in $leaguePage.results)
            {
                $teamId = $team.entry;
                $teamurl = (API-URL "team" "$teamId");
                $teamName = EncodeString $team.entry_name;
                $manager = EncodeString $team.player_name;
                $score = $team.total;
                $rank = $team.rank;
                Write-Output "Load gameweek history for $teamName";
                $gameweekHistoryJson = Get-Data $session $teamurl;
                foreach($gameweek in $gameweekHistoryJson.current)
                {
                    $valueParser = ($gameweek.value).ToString();
                    $value = "�" + $valueParser.SubString(0, $valueParser.length - 1) + '.' + $valueParser.SubString($valueParser.length - 1, 1);
                    $unstructured += New-Object PsObject -Property @{
                                                             GameWeek = $gameweek.event;
                                                             GameWeekPoints = $gameweek.points;
                                                             PointsOnBench = $gameweek.points_on_bench;
                                                             TransfersMade = $gameweek.event_transfers;
                                                             TransfersCode = $gameweek.event_transfers_cost;
                                                             OverallPoints = $gameweek.total_points;
                                                             TeamValue = $value;
                                                             TeamId = $teamId;
                                                             Manager = $manager;
                                                             TeamName = $teamName;
                                                           };
                }
            }
        }
    }
    
    $rankedStructure = $unstructured | Group-Object GameWeek | ForEach-Object { 
          $rank = 0
          $_.Group | Sort-Object OverallPoints -Descending | Select-Object *, @{ 
          n='GameWeekRank'; e={ Set-Variable -Scope 1 rank ($rank+1); $rank } 
          }
    };

    return $rankedStructure;
}
