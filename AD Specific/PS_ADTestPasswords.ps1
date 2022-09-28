####################################################################
# Test AD credentials 
#
# Used for testing user\pass pairs in bulk against Active Directory
#
# Requirements: "input.csv" with two columns: username & password
#
# Outputs: results to csv file
# --------------------------------------------------------
# Ver  init  Date     Notes
# ---  ---   -------- -------------------------------------
# 1.0  MAB   20220831 - Created initial script
# 1.1  MAB   20220928 - Added SamAccountName check
#                       Created email conversion
#                       Added @UnseenUniversity.edu and @mail.UnseenUniversity.edu checks
#                       Logs if AD account can't be found for check
#                       Added deliminator for REN-ISAC format
#                       Added emaildomain variable for portability
#                       Updated output
#
#####################################################################

#######################################################
# User Variables
#######################################################

$deliminator=":";  # set the import file deliminator
$importFile=".\input.csv"; #set the import file and path
$resultsFile=".\Results"; #set the results prepended filename and path 
$emaildomain = "UnseenUniversity.edu"

#######################################################
# Functions
#######################################################

function WriteLog ($Destinaton, $Msg)
	{
		$OUTPUT = ""+$Msg  
		Add-Content -Path $Destinaton -Value $OUTPUT -Force
	} 
    
function Check-ADAuth 
    {
    param($NAME,$PASS,$ORIGINALNAME)

    ###################################################
    # Check AD to see if the password is good\bad
    # THIS INCREMENTS BADPASSWORD COUNT!!!
    ###################################################

    $RESULT = (New-Object DirectoryServices.DirectoryEntry "",$NAME,$PASS).psbase.name -ne $null
    #$TIMESTAMP = $Date.ToString("yyyyMMdd,hhmmss")

    WriteLog -Destinaton $PRIMARYLOG -Msg "$NAME,$PASS,$RESULT,$ORIGINALNAME"

    if ($RESULT -like "TRUE")
        {
        Write-Host "PASSWORD WORKS - $ORIGINALNAME - $NAME" -fore red
        }
    else
        {
        Write-Host "PASSWORD FAILS - $ORIGINALNAME - $NAME" -fore green
        }
    }

function ReturnSamAccountName
    {
    param($NAME)
    
    # Take email address in and determine if it's a valid address
    $emailName=$NAME.Split("@")[0]

    #write-host "Received $NAME and the root is $emailName"

    #######
    $tempName=$null
    $testEmail=$null
    $SamAccountName=$null
    #######

    ###########################################
    # Add traps for valid email domains below # 
    ###########################################

    # Search for the base email format for $emaildomain 
    $testEmail=$emailName+'@'+$emaildomain 
    #write-host $testEmail
    $tempName = Get-ADUser -Filter {Emailaddress -eq $testEmail} -Properties SamAccountName | Select SamAccountName
    $SamAccountName = $tempName.SamAccountName
    #write-host "Check 1: $SamAccountName"


    $testEmail=$emailName+'@mail.'+$emaildomain 
    #write-host $testEmail
    # Search for the mail.$emaildomain  format 
    if ($tempName -eq $null)
        {
        $tempName = Get-ADUser -Filter {Emailaddress -eq $testEmail} -Properties SamAccountName | Select SamAccountName
        $SamAccountName = $tempName.SamAccountName
        #write-host "Check 2: $SamAccountName"
        }
    
    ############################################################################
    ## ADD ANY ADDITIONAL FORMATS ABOVE HERE - COPY THE ABOVE CHANGE THE FORMAT
    ############################################################################

    # If $tempName is still null, nothing was found
    if ($tempName -eq $null)
        {
        #write-host "Check 3: Found nothing for $NAME"
        }

    # Return the value for whatever we found
    return $SamAccountName
    }

#####################################################
# OUTPUT SETUP
#####################################################
$DATE = Get-Date
$DATETIME = $Date.ToString("yyyyMMdd-hhmmss")
$PRIMARYLOG="$resultsFile-$DATETIME.csv"  
WriteLog -Destinaton $PRIMARYLOG -Msg "Username,Password,Result,Notes"

#####################################################
# INPUT SETUP
#####################################################
$Incoming = Import-Csv -Path $importFile -Header name,pass -Delimiter "$deliminator"

#####################################################
# Handling
#####################################################

foreach ($account in $Incoming)
    {
  
    $USERNAME = $account.name
    $SAMACCOUNT = $NULL
    $PASSWORD = $account.pass
    
    if (($USERNAME.Contains('@')))
        {
        $SAMACCOUNT=ReturnSamAccountName($USERNAME)
        if ($SAMACCOUNT -eq $null)
            {
            ####################################################
            # It looked like an email address, we sent it to find 
            # an AD samaccountname, but nothing existed.
            # value is $null and we can trap that later
            ####################################################
            }
        }
    else 
        {
        ####################################################
        ### It didn't look like an email address
        ### Let's assume we took in a list of AD usernames
        ### Check to see if that AD account exists
        ####################################################
        $tempName = Get-ADUser -Filter {SamAccountName -eq $USERNAME} -Properties SamAccountName | Select SamAccountName
        $SAMACCOUNT = $tempName.SamAccountName
        }
    
    ##########
    if ($SAMACCOUNT -eq $NULL)
        {
        Write-Host "AD ACCOUNT NOT FOUND - $USERNAME - NO ACTION POSSIBLE" -fore Yellow
        WriteLog -Destinaton $PRIMARYLOG -Msg "$USERNAME,$PASSWORD,ACCOUNT NOT FOUND,SAMACCOUNTNAME returned empty"
        }
    else
        {
        Check-ADAuth -name $SAMACCOUNT -pass $PASSWORD -original $USERNAME
        }
    }
####################################################
# Warn about the badpassword account item
####################################################
write-host ""
write-host ""
write-host "***********************************************************************************************************" -fore Yellow
write-host "* Please be aware that the running of this script increases BadPasswordCount for each account it touches. *" -fore Yellow
write-host "***********************************************************************************************************" -fore Yellow
