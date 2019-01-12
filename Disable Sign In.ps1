Write-Host "-------------------------------------------------"
Write-Host "-----------------Disable Sign In-----------------"
Write-Host "-------------------------------------------------"
Write-Host "Gets all users with the 'Minecraft Education' "
Write-Host "job title and disables sign in so users can't "
Write-Host "sign in at home."
Write-Host ""
Write-Host "Script written by Luke Gackle"
Write-Host "-------------------------------------------------"
Write-Host ""

Import-Module -Name MSStore

$credential = Get-Credential -Credential "username@yourdomain.com"

Connect-MsolService -Credential $credential

#Get all users with Job Title 'Minecraft Education'
$users = Get-Msoluser -Title "Minecraft Education"

foreach($user in $users){
if(-Not($user.'UserPrincipalName' -eq 'username@yourdomain.com')){
   Set-MsolUser -UserPrincipalName $user.'UserPrincipalName'  -BlockCredential $true
   Write-Host $user.'UserPrincipalName' "Sign In disabled" -ForegroundColor Green

}


}

Write-Host "Process is complete"
Read-Host "Press ENTER to exit"







