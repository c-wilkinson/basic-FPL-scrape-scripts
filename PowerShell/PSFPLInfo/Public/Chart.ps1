Add-Type -AssemblyName System.Windows.Forms.DataVisualization
Add-Type -AssemblyName Microsoft.VisualBasic

function Chart
{
<#
    .SYNOPSIS
        Create the chart
    .DESCRIPTION
        This function creates a league chart based on 
        the league object passed in.
#> 
    [CmdletBinding()]
	[OutputType([object])]
    param(
        [Parameter(Mandatory=$true)][object]$league
    )
    $totalPlayers = $league.Count;
    Write-Verbose "League has $totalPlayers players";
    $leagueChart = New-object System.Windows.Forms.DataVisualization.Charting.Chart;
    $leagueChart.Width = (38 * 10) + 1000;
    $leagueChart.Height = ($totalPlayers * 10) + 1000;
    $leagueChart.BackColor = [System.Drawing.Color]::White;
    [void]$leagueChart.Titles.Add("FPL League History");
    $leagueChart.Titles[0].Font = "Arial,20pt";
    $leagueChart.Titles[0].Alignment = "topLeft";
    $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea;
    $chartarea.Name = "ChartArea1";
    $chartarea.AxisY.Title = "Rank";
    $chartarea.AxisX.Title = "Gameweek";
    $chartarea.AxisX.Interval = 1;
    $chartarea.AxisX.IsStartedFromZero = $false;
    $chartarea.AxisX.Minimum = 1;
    $chartarea.AxisX.Maximum = 38;
    $chartarea.AxisY.Interval = 1;
    $chartarea.AxisY.IsReversed = $true;
    $chartarea.AxisY.IsStartedFromZero = $false;
    $chartarea.AxisY.Maximum = $totalPlayers;
    $chartarea.AxisY.Minimum = 1;
    $legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend;
    $legend.name = "Legend1";
    $leagueChart.Legends.Add($legend);
    $leagueChart.ChartAreas.Add($chartarea);
    foreach($team in $league)
    {
        $manager = $team.Manager;
        if ($manager)
        {
            Write-Verbose "Adding $manager to chart";
            [void]$leagueChart.Series.Add($manager);
            $leagueChart.Series[$manager].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line;
            $leagueChart.Series[$manager].BorderWidth = 3;
            $gameweekList = @();
            $gameweekRankList = @();
            foreach($week in $team.GameWeekHistory)
            {
                $gameweekList += $week.GameWeek -as [int];
                $gameweekRankList += $week.GameWeekRank -as [int];
            }

            $leagueChart.Series[$team.Manager].Points.DataBindXY($gameweekList, $gameweekRankList);
        }
    }

    return $leagueChart;
}