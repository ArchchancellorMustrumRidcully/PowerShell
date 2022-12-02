##############################
# AD Group Member Search
# BeaneM
# 2022-01-25  MAB v1.3
# 2022-12-02  MAB v1.4 Changed output to individual groups
##############################
# Published to GitHub
# 2020-10-02
##############################

<#
    .SYNOPSIS
        Search for matching AD Groups and print members to screen
    .DESCRIPTION
        Take input and search for a specific match and if not, found, then any matching AD Groups.  Print any found members to the screen.
        Note(s):
            - permutation search is *bidirectional* and not anchored at start

    .PARAMETER undefined
        The AD Group name
        
    .INPUTS
        undefined 
       
    .OUTPUTS
        No outputs. Screen only
 
    .EXAMPLE
        PS_ADGroupMembers.ps1 SecGrp_Wizards
    #>
    
### USER VARIABLES ####
$OUTPUTDIR="C:\temp\"
    
$param1=$args[0]

if ($param1.length -lt  1)
    {
    write-host("We need a name...")
    }
else
    {
    ## Check to see if the group exists in the first place ##
    #Set-Content -Path $OUTPUT -Value "" -Force
        
        try
            {
            $GroupExists = Get-ADGroup -Identity $param1 -ErrorAction:SilentlyContinue
            $MyGroups = get-adgroup -Filter "name -like '$param1'" -Properties * | select -expandproperty name 
            foreach ($MG in $MyGroups) 
                {
                write-host ""
                write-host "Group: $MG"
                $OUTPUT=$OUTPUTDIR+$MG+".csv"
                Set-Content -Path $OUTPUT -Value "Group,Individual,Email" -Force
                #Add-Content -Path $OUTPUT -Value "*************************" -Force
                #Add-Content -Path $OUTPUT -Value $MG -Force
                #Add-Content -Path $OUTPUT -Value "*************************" -Force
                $MyUsers = Get-ADGroupMember -Identity $MG -Recursive | select -expandproperty samaccountname, email
                if ($MyUsers.count -gt 0)
                    {
                    $LISTCOUNTER=1
                    $MyUsers = $MyUsers | Sort-Object
                    foreach ($MU in $MyUsers) 
                        {
                        $ME = Get-ADUser -Identity $MU -properties mail | Select -expandproperty mail
                            write-host "[$LISTCOUNTER] $MU"
                            Add-Content -Path $OUTPUT -Value "$MG,$MU,$ME" -Force
                        #Add-Content -Path ADGroupmembers2.txt -Value "       [$LISTCOUNTER] $MU" -Force
                        Add-Content -Path $OUTPUT -Value "$MG,$MU" -Force
                        $LISTCOUNTER++
                        }
                    }
                else 
                    {
                    write-host "No members"
                    }
                }
                write-host ""
                write-host "If you would like to see all permutations of $param1, try leaving a letters off the end to make other possibilities appear.  Example:" -ForegroundColor Green
                $shorter = $param1.Substring(0,$param1.Length-6)
                write-host "PS_ADGroupMembers.ps1 $shorter" -ForegroundColor Green
            }   
        catch
            {
            write-host ""
            write-host "Unable to find $param1 specifically, let's check for permutations."  -ForegroundColor Yellow
                $MyGroups = get-adgroup -Filter "name -like '*$param1*'" -Properties * | select -expandproperty name
                foreach ($MG in $MyGroups) 
                    {
                    $OUTPUT=$OUTPUTDIR+$MG+".csv"
                    Set-Content -Path $OUTPUT -Value "Group,Individual,Email" -Force
                    write-host ""
                    write-host "Group: $MG"
                    #Add-Content -Path $OUTPUT -Value "*************************" -Force
                    #Add-Content -Path $OUTPUT -Value $MG -Force
                    #Add-Content -Path $OUTPUT -Value "*************************" -Force

                    $MyUsers = Get-ADGroupMember -Identity $MG -Recursive | select -expandproperty samaccountname
                    
                    #$MyUsers = Get-ADGroupMember -Identity $MG -Recursive | select -expandproperty samaccountname
                    #$MyUsers = Get-ADGroupMember -Identity $MG -Recursive | Get-ADUser -Properties SamAccountName,GivenName,sn,Mail | Select SamAccountName,GivenName,sn,Mail 
                    #| Export-CSV -Path “C:\Temp\GroupMembers.csv” -NoTypeInformation
                    if ($MyUsers.count -gt 0)
                        {
                        $LISTCOUNTER=1
                        $MyUsers = $MyUsers | Sort-Object
                        foreach ($MU in $MyUsers) 
                            {
                            $ME = Get-ADUser -Identity $MU -properties mail | Select -expandproperty mail
                            write-host "[$LISTCOUNTER] $MU"
                            Add-Content -Path $OUTPUT -Value "$MG,$MU,$ME" -Force
                            $LISTCOUNTER++
                            }
                        }
                    else 
                        {
                        write-host "No members"
                        }
                }
            # End of Group Check
            write-host "" -ForegroundColor green -BackgroundColor black
            write-host "------------------------------------------------------" -ForegroundColor green -BackgroundColor black
            write-host "**** CSV Export at $OUTPUT **** " -ForegroundColor green -BackgroundColor black
            write-host "------------------------------------------------------" -ForegroundColor green -BackgroundColor black
            write-host "" -ForegroundColor green -BackgroundColor black
            }
        }
