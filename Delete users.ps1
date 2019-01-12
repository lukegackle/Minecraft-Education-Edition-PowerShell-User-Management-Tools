Write-Host "-------------------------------------------------"
Write-Host "------------------Delete Users-------------------"
Write-Host "-------------------------------------------------"
Write-Host "Deletes all users with the Job Title "
Write-Host "'Minecraft Education' the script will also check "
Write-Host "for licensed accounts without the job title and "
Write-Host "output them for attention."
Write-Host ""
Write-Host "Script written by Luke Gackle"
Write-Host "-------------------------------------------------"
Write-Host ""


Import-Module -Name MSStore

$credential = Get-Credential -Credential "you@yourdomain.com"

Connect-MsolService -Credential $credential

Connect-AzureAD -Credential $credential

Connect-MSStore -Credentials $credential


Grant-MSStoreClientAppAccess

$users = Get-Msoluser -Title "Minecraft Education"

foreach($user in $users){
if(-Not($user.'UserPrincipalName' -eq 'you@yourdomain.com')){
    Write-Host "Deleting " $user.'UserPrincipalName'
    
    #Remove Minecraft License
    if(Remove-MSStoreSeatAssignment -ProductId CFQ7TTC0K5DR -SkuId 0002 -Username $user.'UserPrincipalName')
    {
        Write-Host "Minecraft Education Edition license removed for " $user.'UserPrincipalName'
    }
    else{
        Start-Sleep -Seconds 10
        if(Remove-MSStoreSeatAssignment -ProductId CFQ7TTC0K5DR -SkuId 0002 -Username $user.'UserPrincipalName'){
            Write-Host "Minecraft Education Edition license removed for " $user.'UserPrincipalName'
        }
        else{
            Write-Host "Failed to remove Minecraft Education Edition License for " $user.'UserPrincipalName' -ForegroundColor Red
        }
    }

    #Remove user from O365
    if(Get-MsolUser -UserPrincipalName $user.'UserPrincipalName' | Remove-MsolUser -Force){
        Write-Host $user.'UserPrincipalName' "Successfully Removed"
    }
}


}



#Check if any unused licenses need to be reclaimed
$RemainingLicenses = Get-MSStoreSeatAssignments -ProductId CFQ7TTC0K5DR -SkuId 0002

foreach($license in $RemainingLicenses){
$objID = $license.'assignedTo'.replace('{',"")
$objID = $objID.replace('}',"")

try{
    Get-AzureADUser -ObjectId $objID
}
catch{
    Remove-MSStoreSeatAssignment -ProductId CFQ7TTC0K5DR -SkuId 0002 -Username $objID
    Write-Host "Removing License"
}

}

Write-Host "Process is complete"
Read-Host "Press ENTER to exit"