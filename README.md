# PlexProjects

# PlexCheck (originally written by @sup3rmark - modified by @twilliamsj
A Powershell script to report on movies recently added to your Plex library. It uses the Plex API as well as OMDBapi.com (the Open Movie Database) to fetch information on each movie.

Requirements:

Windows
Powershell
Credentials stored in Windows Credential Manager
Download [Get-CredentialFromWindowsCredentialManager.ps1 from 40a](https://gist.github.com/40a/7892466) 
This should be relatively easy to set up for someone running their server on a Windows machine, but give me a second and I'll have a write-up for those who might not know what to do.
Acquire an apikey from http://www.omdbapi.com/apikey.aspx

# Download PlexCheck.ps1 to your computer from link above. (originally written by @sup3rMark)
This script has small modification to update the script to work now. 

Changes include:
adding OMDBAPI key variable
add option to better differentiate TV Series from movies with the same name
add handling of TV show names that include the year in parenthesis i.e. "Deception (2018)" Plex names shows like this to differentiate shows with the same name.  (in this case, "Deception (2013)")
add loop to send email to multiple email addresses instead of just yourself without adding parameters at launch of .ps1


Download [Get-CredentialFromWindowsCredentialManager.ps1 from 40a](https://gist.github.com/40a/7892466) (this forked version is properly set up as a module that contains the Get-StoredCredential function; the original from Tobias Burger will not work as it doesn't have the function in it)

Change the .ps1 extension on Get-CredentialFromWindowsCredentialManager.ps1 to .psm1, and save it to C:\Users[username]\Documents\WindowsPowershell\Modules\Get-CredentialFromWindowsCredentialManager.

Open a Powershell prompt and run the command

        Set-ExecutionPolicy Unrestricted
 
Store the credentials of the email address you want to send the email from in Windows Credential Manager. Instructions here. You should store them with "PlexCheck" as the "Internet or network address" value to avoid having to specify a credential name when running the script. For username and password, enter the credentials for the email address you want to send the email as.

Run the script! You can run from a Powershell prompt, or by right-clicking and selecting Run.

Default behavior:

    .\PlexCheck.ps1

This will run the script with default values:

It will assume you're running it from the same box that your Media Server is running on. As such, the default IP is 127.0.0.1.
It uses the default Plex port, 32400.
The sender email address will be what's defined in your credentials in Windows Credential Manager.
The to address, unless otherwise specified, will be the same as the sender address. Change it at run-time.- or create a list of email addresses to send to in an email.txt file.  
This defaults to Gmail's SMTP server settings, but that can be overridden with parameters. To send from a Gmail account, "Access for less secure apps" must be turned on. Instructions here.
This will send over SSL, and this can't be overridden. Just do it.
This defaults to a 14-day lookback period, but that can be changed, if that's what you're into.
Here's an example of how to run it with all the values changed:


    .\PlexCheck.ps1 -cred foo -url 10.0.0.100 -port 12345 -days 14 -emailTo 'test@email.com' -smtpServer 'smtp.server.com' -smtpPort 132
