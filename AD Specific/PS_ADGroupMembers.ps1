##############################
# AD Group Member Search
# BeaneM
# 2020-10-02
# v1.0
##############################
# Published to GitHub
# 2020-10-02
##############################

<#
    .SYNOPSIS
        Search for matching AD Groups and print members to screen
    .DESCRIPTION
        Take input and search for any matching AD Groups, then print members to the screen.
        Note(s):
            - search is *bidirectional* and not anchored at start

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
        $MyGroups = get-adgroup -Filter "name -like '*$param1*'" -Properties * | select -expandproperty name
        foreach ($MG in $MyGroups) {
            write-host ""
            write-host "Group: $MG"
            $MyUsers = Get-ADGroupMember -Identity $MG -Recursive | select -expandproperty  name
            if ($MyUsers.count -gt 0){
                        foreach ($MU in $MyUsers) {
                        write-host "Member: $MU"
                        }
                    }
            else {
                write-host "No members"
                }
            }
}