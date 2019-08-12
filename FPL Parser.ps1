cls
Write-Host "Authenicate with the FPL website" -ForegroundColor Green
$Credential = Get-Credential -Message 'Please enter your FPL login details'
$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.19 Safari/537.36"
$Uri = 'https://users.premierleague.com/accounts/login/'
$LoginResponse = Invoke-WebRequest -Uri $Uri -SessionVariable 'FplSession' -UseBasicParsing
$CsrfToken = $LoginResponse.InputFields.Where{$_.name -eq 'csrfmiddlewaretoken'}.value
$Response = Invoke-WebRequest -Uri $Uri -WebSession $FplSession -Method 'Post' -UseBasicParsing -Body @{
    'csrfmiddlewaretoken' = $CsrfToken
    'login'               = $Credential.UserName
    'password'            = $Credential.GetNetworkCredential().Password
    'app'                 = 'plfpl-web'
    'redirect_uri'        = 'https://fantasy.premierleague.com/a/login'
    'user-agent'          = $UserAgent
}
Write-Host "Wipe Wipe History Table" -ForegroundColor Green
$database = "FPL"
$server = "(local)"
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=$server;Integrated Security=SSPI;Initial Catalog=$database");
$sqlText = "IF EXISTS ( SELECT  1
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[GameweekHistory]')
                    AND type IN ( N'U' ) )
BEGIN
    DROP TABLE dbo.GameweekHistory;
END;

CREATE TABLE dbo.GameweekHistory
    (
      ID INT IDENTITY(1, 1),
      GAMEWEEK VARCHAR(12),
      TEAMID INT,
      MANAGER NVARCHAR(50),
      TEAM NVARCHAR(100),
      GAMEWEEKPOINTS INT,
      POINTSONBENCH INT,
      TRANSFERSMADE INT,
      TRANSFERSCOST INT,
      TEAMVALUE VARCHAR(7),
      OVERALLPOINTS INT
      CONSTRAINT CL_ID PRIMARY KEY CLUSTERED ( ID ),
      CONSTRAINT UN_GWTEAM UNIQUE NONCLUSTERED ( GAMEWEEK, TEAMID )
    );";
$cmd = new-object System.Data.SqlClient.SqlCommand($sqlText, $connection);
$cmd.CommandTimeout = 0;
$connection.Open();
$cmd.ExecuteNonQuery() | Out-Null;
$connection.Close();
Write-Host "Load basic team information from FPL" -ForegroundColor Green
$leagueTableJson = Invoke-RestMethod -Uri "https://fantasy.premierleague.com/api/leagues-classic/36351/standings/" -WebSession $FplSession -UseBasicParsing
# Note, we could use this for multiple pages, if we decided we needed to, as we can see the "next page" here
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=$server;Integrated Security=SSPI;Initial Catalog=$database");
$sqlText = "INSERT INTO [dbo].[GameweekHistory]
        (
          [GAMEWEEK],
          [TEAMID],
          [MANAGER],
          [TEAM],
          [GAMEWEEKPOINTS],
          [POINTSONBENCH],
          [TRANSFERSMADE],
          [TRANSFERSCOST],
          [TEAMVALUE],
          [OVERALLPOINTS]
        )
VALUES  (
          @GAMEWEEK,
          @TEAMID,
          @MANAGER,
          @TEAM,
          @GAMEWEEKPOINTS,
          @POINTSONBENCH,
          @TRANSFERSMADE,
          @TRANSFERSCOST,
          @TEAMVALUE,
          @OVERALLPOINTS
        )";
$cmd = new-object System.Data.SqlClient.SqlCommand($sqlText, $connection);
$cmd.CommandTimeout = 0;
$connection.Open();
foreach($leaguePage in $leagueTableJson.standings)
{
    foreach($team in $leaguePage.results)
    {
        $teamurl = "https://fantasy.premierleague.com/api/entry/"+$team.entry+"/history/";
        $teamName = $team.entry_name;
        $manager = $team.player_name;
        $score = $team.total;
        $rank = $team.rank;
        $teamId = $team.entry;
        Write-Host "Load gameweek history for $teamName" -ForegroundColor Green
        $gameweekHistoryJson = Invoke-RestMethod -Uri $teamurl -WebSession $FplSession -UseBasicParsing
        foreach($gameweek in $gameweekHistoryJson.current)
        {
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@GAMEWEEK', [Data.SQLDBType]::VarChar, 12))).Value = $gameweek.event;
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@TEAMID', [Data.SQLDBType]::Int))).Value = $teamId;
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@MANAGER', [Data.SQLDBType]::VarChar, 50))).Value = $manager;
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@TEAM', [Data.SQLDBType]::VarChar, 100))).Value = $teamName;
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@GAMEWEEKPOINTS', [Data.SQLDBType]::Int))).Value = $gameweek.points;
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@POINTSONBENCH', [Data.SQLDBType]::Int))).Value = $gameweek.points_on_bench;
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@TRANSFERSMADE', [Data.SQLDBType]::Int))).Value = $gameweek.event_transfers;
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@TRANSFERSCOST', [Data.SQLDBType]::Int))).Value = $gameweek.event_transfers_cost;
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@OVERALLPOINTS', [Data.SQLDBType]::Int))).Value = $gameweek.total_points;
            $valueParser = ($gameweek.value).ToString();
            $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter('@TEAMVALUE', [Data.SQLDBType]::VarChar, 7))).Value = "£" + $valueParser.SubString(0, $valueParser.length - 1) + '.' + $valueParser.SubString($valueParser.length - 1, 1);
            $cmd.Prepare();
            $cmd.ExecuteNonQuery() | Out-Null;
            $cmd.Parameters.Clear();
        }
    }
}
$connection.Close();
