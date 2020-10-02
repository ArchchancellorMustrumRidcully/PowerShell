##############################
# AD Group Member Search
# BeaneM
# 2020-10-02
# v1.2
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
    
$param1=$args[0]
if ($param1.length -lt  1){
    write-host("We need a name...")
    }
else {
        $Highlander = 0
        ## Check to see if the group exists in the first place ##
        try
            {
            $GroupExists = Get-ADGroup -Identity $param1 -ErrorAction:SilentlyContinue
            $MyGroups = get-adgroup -Filter "name -like '$param1'" -Properties * | select -expandproperty name
            foreach ($MG in $MyGroups) 
                {
                write-host ""

                write-host "Group: $MG"
                $MyUsers = Get-ADGroupMember -Identity $MG -Recursive | select -expandproperty  name
                if ($MyUsers.count -gt 0)
                    {
                    foreach ($MU in $MyUsers) 
                        {
                        write-host "Member: $MU"
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
                    
                    write-host ""
                    write-host "Group: $MG"
                    $MyUsers = Get-ADGroupMember -Identity $MG -Recursive | select -expandproperty  name
                    if ($MyUsers.count -gt 0)
                        {
                        foreach ($MU in $MyUsers) 
                            {
                            write-host "Member: $MU"
                            }
                        }
                    else 
                        {
                        write-host "No members"
                        }
                    }
                }
            }
        
