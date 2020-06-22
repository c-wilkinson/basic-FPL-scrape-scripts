function Get-League
{
<#
    .SYNOPSIS
        Create correct league structure
    .DESCRIPTION
        This function makes a structure where the team is the
        key and the gameweek list object is the value.
    .PARAMETER leagueId
        This is an integer representing the league identification number 
        for the mini-league to be parsed to an object.  This can be found
        by clicking on your mini-league, then looing at the browser URL, 
        which should be something like -
        https://fantasy.premierleague.com/leagues/{someNumberHere}/standings/c
        The {someNumberHere} value is the league identification number.
    .PARAMETER session
        This is a websession authenticated for use on the FPL server.  You
        can generate this by using the Authenticate function of this module.
    .OUTPUTS
        System.Object.  Get-League returns an object of the mini-league data.
    .EXAMPLE
        C:\> $league = Get-League -leagueId $leagueId -session $session;
    .EXAMPLE
        C:\> $league = Get-League -leagueId 1000 -session (Authenticate -credential (New-Object System.Management.Automation.PSCredential('some@e-mail.com', ('somePassword' | ConvertTo-SecureString -asPlainText -Force))));
    .EXAMPLE
        C:\> $league = Get-League $leagueId $session;
    .EXAMPLE
        C:\> $league = Get-League 1000 (Authenticate -credential (New-Object System.Management.Automation.PSCredential('some@e-mail.com', ('somePassword' | ConvertTo-SecureString -asPlainText -Force))));
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
                                                         GameWeekNumber = $info.GameWeekNumber;
                                                      };
            if ($currentdata)
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