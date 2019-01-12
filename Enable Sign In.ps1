Write-Host "-------------------------------------------------"
Write-Host "-----------------Enable Sign In------------------"
Write-Host "-------------------------------------------------"
Write-Host "Gets all users with the 'Minecraft Education' "
Write-Host "job title and enables sign in so users can "
Write-Host "sign into Minecraft Education Edition in class."
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
   Set-MsolUser -UserPrincipalName $user.'UserPrincipalName'  -BlockCredential $false
   Write-Host $user.'UserPrincipalName' "Sign In enabled" -ForegroundColor Green
}

}

Write-Host "Process is complete"
Read-Host "Press ENTER to exit"







