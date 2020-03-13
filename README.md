# basic-FPL-scrape-scripts
This repository represents my interest in numbers, fantasy football and experimentation with languages I don't often use.  I'll split the repository by language then by title.  The whole thing is covered under a "do as you wish" license.

[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)

### PowerShell
#### PSLInfo
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)[![Workflow Status](https://github.com/c-wilkinson/basic-FPL-scrape-scripts/workflows/Create%20Mini-League%20Chart/badge.svg)](https://github.com/c-wilkinson/basic-FPL-scrape-scripts/actions)

https://www.powershellgallery.com/packages/PSFPLInfo

This is a PowerShell module that scrapes the FPL website and generates objects that you can use.  Usage is simple:
Install-Module -Name PSFPLInfo -Force
Import-Module -Name PSFPLInfo -Force

$session = Authenticate {your login e-mail} {your login password};
$league = Get-League {your mini league ID} $session;
$chart = Chart $league;

The three objects generated there are an FPL websession (used to allow you to scrap your mini-league data), a mini-league object (consisting of Manager, TeamName, TeamId, TeamValue and an array of GameWeekHistory) and a chart object.  The chart object can be saved by calling "$chart.SaveImage("someFile.png", "PNG");", creating a line chart of the history of your mini-league rankings.
