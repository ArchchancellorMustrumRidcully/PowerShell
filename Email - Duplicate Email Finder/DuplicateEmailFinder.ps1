##############################
# AD Duplicate Email Finder
# BeaneM
# 2020-10-08
# v1.0
##############################
# Published to GitHub
# 2020-10-08
##############################
# Purpose: Unseen University uses four fields to set primary email + 
# aliases for Guugle email accounts.  Occasionally due to things like
# name changes, a duplicate entry can appear.  This script pulls all 
# four fields (scheduled daily) and sends an error report if a duplicate
# is found.
####################################

############ Variables ##################
$EXPORTTOCSV = 0  # set to 1 if export file is desired
$WriteHost = 0         # write to screen if run manually
$EmailActive = 1       # email the output if one is found

####################################
# Get Required Modules

Import-Module ActiveDirectory

#####################################
# Semi-Non-User Variable Priming Mechanism
$Date = (Get-Date)  			# Overwritten Later 
$ScriptDir = Get-Location	# Change to "c:\Directory of script\" if run as a scheduled task

#####################################
## User Variables #########################
## Target Domani and OU ####################

$DOMAIN = "DC=UnseenUniversity,DC=edu"
$OU ="" #Everyone
#$OU = "OU=UnseenUniversity Alumni,"
#$OU = "OU=Students,OU=UnseenUniversity Users,"
#$OU = "OU=Faculty and Staff,OU=UnseenUniversity Users,"

######################################
## SMTP Settings ##########################

$smtpsettings = @{
	To = "Alerts-l@UnseenUniversity.edu"
	From = "alerts@UnseenUniversity.edu "
	SmtpServer = "crystalball.UnseenUniversity.edu"
	Subject = "Duplicate Email Addresses - $OU$DOMAIN"
}

###########################################################
### HTML OUTPUT ##############################################

$htmlhead = "<html>
				<style>
				BODY{font-family: Arial; font-size: 8pt;}
				H1{font-size: 22px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				H2{font-size: 18px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				H3{font-size: 16px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
				TH{border: 1px solid #969595; background: #dddddd; padding: 5px; color: #000000;}
				TD{border: 1px solid #969595; padding: 5px; }
				td.pass{background: #B7EB83;}
				td.warn{background: #FFF275;}
				td.fail{background: #FF2626; color: #ffffff;}
				td.info{background: #85D4FF;}
				</style>
				<body>
                <p><b>List of Duplicate Email Addresses in $OU$DOMAIN</b></p>"

### HTML Footer Information #########################################
$htmltail = "<br><br><b>Location: </b>$env:computername<br><b>Dir: </b>$ScriptDir<br><b>Date: </b>$Date </body></html>"

############################################################
############################################################

####################################################
####################################################
## Do Not Edit Below This Line
####################################################
$date=Get-Date -Format "yyyyMMdd_HH_mm_ss"

$USERS = @()
$SEARCH_OU = "$OU$DOMAIN"
if ($WriteHost -eq 1)
        {write-host "$SEARCH_OU"}

$OUTPUT="DuplicateEmailFinderExport-$DATE.csv"

if ($EXPORTTOCSV -eq 1)
    {
    Add-Content $OUTPUT "SamAccountName,DisplayName,Current_Office,EMail,Field" 
    }

$EmailList = [System.Collections.ArrayList]@()
$EmailList.Add("Email Address") | Out-Null


####################################################
# Start Search and array population
####################################################
$COUNTER = 1
$GetOU = Get-ADUser -SearchBase $SEARCH_OU -Filter *
$USERS = foreach ($User in $GetOU) 
    {
    $HOWMANY = $GetOU.Count
    
    $UserDN = $User.DistinguishedName
    $Name=$User.SamAccountName 
    if ($WriteHost -eq 1)
        {write-host "$COUNTER / $HOWMANY | Processing: $Name"}
    ###################################################################
	# Get AD Properties
	$CurrentUserDetails = Get-ADuser -Identity "$User" -Properties * 
	###################################################################
	###################################################################
	# Set Loop Variables
    ###################################################################

    $Current_SamAccountName=$CurrentUserDetails.sAMAccountName
    $Current_DisplayName=$CurrentUserDetails.DisplayName
    $Current_Email=$CurrentUserDetails.EmailAddress
    $Current_WWW=$CurrentUserDetails.wWWHomePage
    $Current_fax=$CurrentUserDetails.facsimileTelephoneNumber
    $Current_iphone=$CurrentUserDetails.ipPhone

    if ($Current_Email)
        {
        if ($EXPORTTOCSV -eq 1) {        Add-Content $OUTPUT "$Current_SamAccountName,$Current_DisplayName,$Current_Office,$Current_Email,Email"  }
        $EmailList.Add($Current_Email)
        }
    if ($Current_WWW)
        {
        if ($EXPORTTOCSV -eq 1) {        Add-Content $OUTPUT "$Current_SamAccountName,$Current_DisplayName,$Current_Office,$Current_WWW,wWWHomepage"  }
        $EmailList.Add($Current_WWW)
        }
    if ($Current_fax)
        {
        if ($EXPORTTOCSV -eq 1) {        Add-Content $OUTPUT "$Current_SamAccountName,$Current_DisplayName,$Current_Office,$Current_fax,facsimileTelephoneNumber"  }
        $EmailList.Add($Current_fax)
        }
    if ($Current_iphone)
        {
        if ($EXPORTTOCSV -eq 1) {        Add-Content $OUTPUT "$Current_SamAccountName,$Current_DisplayName,$Current_Office,$Current_iphone,ipPhone"  }
        $EmailList.Add($Current_iphone)
        }
    $COUNTER++
    }

    if ($WriteHost -eq 1)
        {write-host "Finished queuing.  Checking array for duplicates"}
    $EmailUnique=$EmailList | select –unique
    
    # PassThru removes the compare stamp on the output
    $Duplicates = Compare-object –referenceobject $EmailUnique –differenceobject $EmailList -PassThru 
    
    $HTMLDuplicates = [System.Collections.ArrayList]@()
    
    
    foreach ($Duplicate in $Duplicates)
        {
        if ($WriteHost -eq 1)
        {write-host "$Duplicate"}
        $HTMLDuplicates.Add($Duplicate + "<br>") | Out-Null 
        }

    if (($EmailActive -eq 1) -AND ($Duplicates -gt 0))
        {
        $html = $HTMLDuplicates | out-string 
        $body = $htmlhead + $html + $htmltail
        Send-MailMessage @smtpsettings -body $body -BodyAsHtml
        }
    
