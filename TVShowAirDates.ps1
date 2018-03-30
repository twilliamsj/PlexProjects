<#
.SYNOPSIS
Pull a list of tv shows from plex library.  Create a spreadsheet with air dates and show status (ended or continuing)
.DESCRIPTION
This list will include information pulled dynamically from OMDBapi.com - the Open Movie Database, and thetvdb.com - the Television Database
.PARAMETERS
See param block for descriptions of available parameters
APIKey is requires for access to omdbapi.com  -  http://www.omdbapi.com/apikey.aspx
Authentication token is required for access to thetvdb.com - https://www.thetvdb.com/?tab=register
#>

param(
    # Required: specify your Plex Token
    #   To find your token, check here: https://support.plex.tv/hc/en-us/articles/204059436-Finding-your-account-token-X-Plex-Token
    #[Parameter(Mandatory = $true)]
    #[string]$Token,
    [string]$Token = '[Your Plex Token Here]',

    #Required: OMDB API Key
    [string]$omdbapi = '[Your OMDBApi key here]',
    
    # Optionally specify IP of the server we want to connect to
    [string]$Url = 'http://127.0.0.1',

    # Optionally define a custom port
    [int]$Port = '32400',

    # Specify the Library ID of any libraries you'd like to exclude
    [int[]]$ExcludeLib = 0

)

#region TheTVDB.com Header info
# TheTVDB Authentication Information
 $TheTVDBAuthentication = @{
    "apikey" = "[your thetvdb api key]"
    "userkey" = "[your userkey / account identifier]" # Account Identifier
    "username" = "[your username]"
}


# Authenticate with TheTVDB API to get a token
try {
    $TheTVDBToken = (Invoke-RestMethod -Uri "https://api.thetvdb.com/login" -Method Post -Body ($TheTVDBAuthentication | ConvertTo-Json) -ContentType 'application/json').token
} catch {
    Write-Host -ForegroundColor Red "Failed to get TheTVDB API Token:"
    Write-Host -ForegroundColor Red $_
    break
}

# Create TheTVDB API Headers
$TVDBHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$TVDBHeaders.Add("Accept", "application/json")
$TVDBHeaders.Add("Authorization", "Bearer $TheTVDBToken")
#endregion

#Gather data from Plex Library
$response = Invoke-WebRequest "$url`:$port/library/sections/1/all/?X-Plex-Token=$Token" -Headers @{"accept"="application/json"}
$jsonlibrary = ConvertFrom-JSON $response.Content
$tvShows = $jsonLibrary.MediaContainer.Metadata |
    Where-Object {$_.type -eq 'show'} |
    Group-Object title


foreach ($show in $tvShows) {
        #set variables for each run
            #Clear-Variable -Name year  # Clear the $year variable in the event that there is no year in the title of the tv show (which is standard)
            $showtitle = $show.name
            $tvshowname = ($showtitle -split {$_-eq "("-or $_-eq")"},3)[0]
            $year = ($showtitle -split {$_-eq "("-or $_-eq")"},3)[1]

            
        # Retrieve show info from the Open Movie Database
             $omdbURL = "omdbapi.com/?apikey=$omdbapi&t=$($tvshowname)&y=$($year)&type=series&r=JSON"
             $omdbResponse = ConvertFrom-JSON (Invoke-WebRequest $omdbURL).content
             $imdbid = $omdbResponse.imdbID
        # Retrieve show status info from the Television Database
             $Results = (Invoke-RestMethod -Uri "https://api.thetvdb.com/search/series?imdbId=$imdbid" -Headers $TVDBHeaders)
             $status = $Results.data
             $showid = $status.id
             $resultsfilter = (Invoke-RestMethod -Uri "https://api.thetvdb.com/series/$showid/filter?keys=airsDayOfWeek,airsTime" -Headers $TVDBHeaders)

        #Creat array with data
                $DataOut = @{
                "Show" = $tvshowname
                "Year" = $omdbResponse.year
                "Status" = $status.status
                "Air Day" = $resultsfilter.data.airsDayOfWeek
                "First Aired" = $resultsfilter.data.airsTime
                "Total # Seasons" = $omdbResponse.totalSeasons
                }

            $airobject = New-Object -TypeName psobject -Property $DataOut
            
            $airobject | export-csv C:\Scripts\tvairdate.csv -NoTypeInformation -Append
            
            }
