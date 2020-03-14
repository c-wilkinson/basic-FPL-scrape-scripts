# basic-FPL-scrape-scripts
This repository represents my interest in numbers, fantasy football and experimentation with languages I don't often use.  I'll split the repository by language then by title.  The whole thing is covered under a "do as you wish" license.

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/c322c6f6792c4d0f9a8d7f2c09786d70)](https://app.codacy.com/manual/c-wilkinson/basic-FPL-scrape-scripts?utm_source=github.com&utm_medium=referral&utm_content=c-wilkinson/basic-FPL-scrape-scripts&utm_campaign=Badge_Grade_Dashboard)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)

[![CodeFactor](https://www.codefactor.io/repository/github/c-wilkinson/basic-fpl-scrape-scripts/badge/master)](https://www.codefactor.io/repository/github/c-wilkinson/basic-fpl-scrape-scripts/overview/master)

### PowerShell
#### PSFPLInfo
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)![Create Mini-League Chart For Work Mini-League](https://github.com/c-wilkinson/basic-FPL-scrape-scripts/workflows/Create%20Mini-League%20Chart%20For%20Work%20Mini-League/badge.svg)![AuthenticationTests](https://github.com/c-wilkinson/basic-FPL-scrape-scripts/workflows/AuthenticationTests/badge.svg)![ChartCreationTests](https://github.com/c-wilkinson/basic-FPL-scrape-scripts/workflows/ChartCreationTests/badge.svg)

https://www.powershellgallery.com/packages/PSFPLInfo

This is a PowerShell module that scrapes the FPL website and generates objects that you can use.  Usage is simple:

```powershell
Install-Module -Name PSFPLInfo -Force; 
Import-Module -Name PSFPLInfo -Force; 

$session = Authenticate {your login e-mail} {your login password};
$league = Get-League {your mini league ID} $session;
$chart = Chart $league;
```

The three objects generated there are an FPL websession (used to allow you to scrap your mini-league data), a mini-league object (consisting of Manager, TeamName, TeamId, TeamValue and an array of GameWeekHistory) and a chart object.  The chart object can be saved by calling:

```powershell
$chart.SaveImage("someFile.png", "PNG");
```

This generates a line graph of the history of your mini-league rankings.
