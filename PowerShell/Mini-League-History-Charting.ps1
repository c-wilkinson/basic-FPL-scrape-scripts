Add-Type -AssemblyName System.Windows.Forms.DataVisualization
Add-Type -AssemblyName Microsoft.VisualBasic

function Authenticate
{
    $Credential = Get-Credential -Message 'Please enter your FPL login details';
    $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.19 Safari/537.36";
    $Uri = 'https://users.premierleague.com/accounts/login/';
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls";
    $LoginResponse = Invoke-WebRequest -Uri $Uri -SessionVariable 'FplSession' -UseBasicParsing;
    $CsrfToken = $LoginResponse.InputFields.Where{$_.name -eq 'csrfmiddlewaretoken'}.value;
    $Response = Invoke-WebRequest -Uri $Uri -WebSession $FplSession -Method 'Post' -UseBasicParsing -Body @{
        'csrfmiddlewaretoken' = $CsrfToken
        'login'               = $Credential.UserName
        'password'            = $Credential.GetNetworkCredential().Password
        'app'                 = 'plfpl-web'
        'redirect_uri'        = 'https://fantasy.premierleague.com/a/login'
        'user-agent'          = $UserAgent
    };

    return $FplSession;
}

function ScrapeFPLWebSite($session, $url)
{
    $json = Invoke-RestMethod -Uri $url -WebSession $session -UseBasicParsing;
    # Sleep, be as kind as possible to the FPL servers!
    Start-Sleep -Seconds 2.5;
    return $json;
}

function EncodeString([string]$string)
{
    # Encoding, ugly fix for bug #6
    $utf8 = [System.Text.Encoding]::GetEncoding(65001);
    $iso88591 = [System.Text.Encoding]::GetEncoding(28591);
    $stringBytes = $utf8.GetBytes($string);
    $stringEncoded = [System.Text.Encoding]::Convert($utf8,$iso88591,$stringBytes);
    $newString = $utf8.GetString($stringEncoded);
    return $newString;
}

function CreateInitialLeagueStructure($jsonArray, $session)
{
    $unstructured = @();
    foreach($json in $jsonArray)
    {
        foreach($leaguePage in $json.standings)
        {
            foreach($team in $leaguePage.results)
            {
                $teamurl = "https://fantasy.premierleague.com/api/entry/"+$team.entry+"/history/";
                $teamName = EncodeString $team.entry_name;
                $manager = EncodeString $team.player_name;
                $score = $team.total;
                $rank = $team.rank;
                $teamId = $team.entry;
                Write-Host "Load gameweek history for $teamName" -ForegroundColor Green;
                $gameweekHistoryJson = ScrapeFPLWebSite $session $teamurl;
                foreach($gameweek in $gameweekHistoryJson.current)
                {
                    $valueParser = ($gameweek.value).ToString();
                    $value = "£" + $valueParser.SubString(0, $valueParser.length - 1) + '.' + $valueParser.SubString($valueParser.length - 1, 1);
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
    
    return $unstructured;
}

function OrderStructure($structure)
{
    $rankedStructure = $structure | Group-Object GameWeek | ForEach-Object { 
          $rank = 0
          $_.Group | Sort-Object OverallPoints -Descending | Select-Object *, @{ 
          n='GameWeekRank'; e={ Set-Variable -Scope 1 rank ($rank+1); $rank } 
          }
    };

    return $rankedStructure;
}

function CreateLeagueStructure($structure)
{
    $leagueTable = @();
    foreach($info in $structure)
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

    return $leagueTable;
}

function CreateChart($league, $form)
{
    $totalPlayers = $league.Count;
    $leagueChart = New-object System.Windows.Forms.DataVisualization.Charting.Chart;
    $leagueChart.Width = ([System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width) - 200;
    if ($form)
    {
        $leagueChart.Height = ([System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height) - 200;
    }
    else
    {
        $leagueChart.Height = ($totalPlayers * 10) + 1000;
    }

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
        [void]$leagueChart.Series.Add($team.Manager);
        $leagueChart.Series[$team.Manager].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line;
        $leagueChart.Series[$team.Manager].BorderWidth = 3;
        $gameweekList = @();
        $gameweekRankList = @();
        foreach($week in $team.GameWeekHistory)
        {
            $gameweekList += $week.GameWeek -as [int];
            $gameweekRankList += $week.GameWeekRank -as [int];
        }

        $leagueChart.Series[$team.Manager].Points.DataBindXY($gameweekList, $gameweekRankList);
    }

    return $leagueChart;
}

function CreateForm($chart, $saveChart)
{
    $Form = New-Object System.Windows.Forms.Form;
    $Form.Text = "PowerShell Chart";
    $SaveButton = New-Object System.Windows.Forms.Button;
    $SaveButton.Text = "Save to desktop";
    $SaveButton.AutoSize = $true;
    $SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right;
    $SaveButton.add_click({$saveChart.SaveImage($Env:USERPROFILE + "\Desktop\Chart.png", "PNG")});
    $Form.controls.add($SaveButton);
    $Form.controls.add($chart);
    $Form.AutoSize = $true; 
    $Form.Add_Shown({$Form.Activate()});
    $Form.ShowDialog();
}

function AuthenticationCheck
{
    $authenticated = $false;
    $retry = 1;
    Write-Host "Attempt to authenticate on the FPL Server" -ForegroundColor Green;
    while (-not $authenticated)
    {
        $session = Authenticate;
        # Test whether or not we're logged in
        $userJson = ScrapeFPLWebSite $session "https://fantasy.premierleague.com/api/me/";
        if (-not ($userJson.player.id)) 
        {
            Write-Host "Invalid credentials, please try again" -ForegroundColor Red;
            $authenticated = $false;  
            $retry++;
            if ($retry -gt 3) 
            {
                throw 'Invalid credentials';
            }
        }
        else
        {
            Write-Host "Successfully authenticated on the FPL Server" -ForegroundColor Green;
            $authenticated = $true;
        }
    }

    return New-Object PsObject -Property @{
                                            Session = $session;
                                            Authenticated = $authenticated;
                                          };
}

function LeagueNumber
{
    $retry = 1;
    $numeric = $false;
    while (-not $numeric)
    {
        Write-Host "Get the league number from the user" -ForegroundColor Green;
        $leagueId = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the league number:', 'League Number');
        $numeric = $leagueId -match '^\d+$';
        $retry++;
        if ($retry -gt 3) 
        {
            throw 'Invalid league ID';
        }

        if (-not $numeric)
        {
            Write-Host "The typed league number is not numeric.  Expecting the numeric value in the league URL between '/leagues/' and '/standings/'" -ForegroundColor Red;
        }
    }

    return New-Object PsObject -Property @{
                                            LeagueID = $leagueId;
                                            Valid = $numeric;
                                          };
}

function GatherUnstructuredLeagueData($leagueId, $session)
{
    $allleagueTablePage = @();
    $pageNumber = 1;
    $loop = $true;
    while ($loop)
    {    
        $leagueTableJson = ScrapeFPLWebSite $session "https://fantasy.premierleague.com/api/leagues-classic/$leagueId/standings/?page_standings=$pageNumber";
        $allleagueTablePage += $leagueTableJson;
        $loop = $leagueTableJson.standings.has_next;
        $pageNumber++;
    }

    return $allleagueTablePage;
}

cls;
$authenticationToken = AuthenticationCheck;
if ($authenticationToken.Authenticated -eq $true)
{
    $leagueToken = LeagueNumber;

    if ($leagueToken.Valid -eq $true)
    {
        $leagueTable = GatherUnstructuredLeagueData $leagueToken.LeagueID $authenticationToken.Session;
        $leagueTable = CreateInitialLeagueStructure $leagueTable $authenticationToken.Session;
        $leagueTable = OrderStructure $leagueTable;
        $leagueTable = CreateLeagueStructure $leagueTable;
        $formChart = CreateChart $leagueTable $true;
        $saveChart = CreateChart $leagueTable $false;
        CreateForm $formChart $saveChart;
    }
}
