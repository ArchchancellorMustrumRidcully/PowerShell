##############################
# AD Account - Get Assigned AD Groups (Non-Recursive)
# BeaneM
# 2021-10-02
# v1.2
##############################
# Published to GitHub
# 2021-06-25
##############################

<#
    .SYNOPSIS
        Search target account for AD Groups and print members to screen (sorted)
    .DESCRIPTION
        Take input and search for a specific match and pull membership info.  Print to the screen as a sorted list.
        

    .PARAMETER undefined
        The AD Username
        
    .INPUTS
        undefined 
       
    .OUTPUTS
        No outputs. Screen only
 
    .EXAMPLE
        PS_ADGetGroups.ps1 RinceWind
    #>

$param1=$args[0]
if ($param1.length -lt  1){
    write-host("We need a name...")
    }
else {
        $WIZZARD =@()
        $WIZZARD  = Get-ADPrincipalGroupMembership $param1 | select -ExpandProperty name
        $WIZZARD  = $WIZZARD  | Sort-Object
            write-host ""
            write-host ""
        foreach ($WIZ in $WIZZARD )
            {

            write-host $WIZ
            
            }
            write-host ""
}