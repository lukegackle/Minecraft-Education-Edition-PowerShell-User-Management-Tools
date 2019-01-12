$host.Runspace.ThreadOptions = "ReuseThread"


Write-Host "-------------------------------------------------"
Write-Host "--------------Create Users from CSV--------------"
Write-Host "-------------------------------------------------"
Write-Host "Creates users from a provided CSV file, the script"
Write-Host "uses the 'First Name' and 'Surname' columns of a "
Write-Host "CSV file to create and license the accounts for "
Write-Host "Minecraft Education Edition."
Write-Host ""
Write-Host "Script written by Luke Gackle"
Write-Host "-------------------------------------------------"
Write-Host ""


#Connection to Office 365 and importing necessary modules
Import-Module -Name MSStore

$credential = Get-Credential -Credential "you@yourdomain.com"

Connect-MsolService -Credential $credential

Connect-AzureAD -Credential $credential

Connect-MSStore -Credentials $credential

Grant-MSStoreClientAppAccess

[System.Collections.ArrayList]$CreatedUsers = @()


#Definition of the function that allows to create the Office 365 users contained in the CSV file.
function Create-Office365Users
{
    param ($sInputFile,$sColumnName)

            # Reading the CSV file
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            
            #Check if > 13 Participants, you can set this to your maximum number of licenses
            [int]$LinesInFile = 0
            $reader = New-Object IO.StreamReader $sInputFile
            while($reader.ReadLine() -ne $null){ $LinesInFile++ }
            $LinesInFile--
            if($LinesInFile -gt 13){
                Write-Host "File contains more than 13 registrations"
                if(Read-Host -Prompt "Type y to continue anyway" -ne "y"){
                    exit
                }
            }
            
            "Loading $InvFile for processing..." 
            $tblDatos = Import-CSV $sInputFile            
        } else { 
            Write-Host "$sInputFile file not found. Stopping the import process!" -ForegroundColor Red
            exit 
        }
        
                 
        # Creating the users
        #Process uses the 'First Name' and 'Surname' column from the .csv file
        Write-Host "Creating Office 365 users ..." -foregroundcolor Green
        
        $pattern = '[^a-zA-Z]'

        foreach ($fila in $tblDatos) 
        { 
            #Getting the data from the csv file, removing hyphens, spaces, and apostrophies
            $f = $fila."First Name".toLower().Trim() -replace $pattern, ''
            $fi = $f[0]
            $l = $fila."Surname".toLower().Trim() -replace $pattern, ''

            $domain = "@yourdomain.com"
            
            $username = $fi + "." + $l + ".MC" + $domain
            $displayName = $f+" "+$l

            Write-Host $username
            $iterations = 0
            while(-Not(New-MsolUser -DisplayName $displayName -FirstName $f -LastName $l -UserPrincipalName $username -LicenseAssignment yourdomain:STANDARDWOFFPACK_STUDENT -Password $sDefaultPassword -PasswordNeverExpires $true -ForceChangePassword $false -UsageLocation AU)){
                Write-Host "Failed to create $username "
                $iterations = $iterations + 1
                $username = $fi + "." + $l + $iterations + ".MC" + $domain
                
            }
            $CreatedUsers.Add($username)
            Write-Host "Created $username"

            #Sleep for 60 seconds - Takes time for AD to propagate in O365 hence causing errors setting job title
            Start-Sleep -Seconds 60
            
            #Set Job Title to Minecraft Education - Use views in O365 Admin to filter users
            $ObjectId = Get-AzureADUser -Filter "userPrincipalName eq '$username'"
            Set-AzureADUser -ObjectId $ObjectId.'ObjectId' -JobTitle "Minecraft Education"
            
            Start-Sleep -Seconds 20

            #Provision Minecraft License
            if(Add-MSStoreSeatAssignment -ProductId CFQ7TTC0K5DR -SkuId 0002 -Username $username)
            {
                Write-Host "$username successfully licensed for Minecraft Education Edition"
            }
            else{
                #Failover support, try again in 10 seconds, MSStore is sometimes tempermental
                Start-Sleep -Seconds 10
                if(Add-MSStoreSeatAssignment -ProductId CFQ7TTC0K5DR -SkuId 0002 -Username $username){
                   Write-Host "$username successfully licensed for Minecraft Education Edition"
                 }
                 else{
                    Write-Host "Failed to add Minecraft Education Edition License for " $username -ForegroundColor Red
                 }
            }

        }
        

        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
        Write-Host "All the users have been Created. The processs is completed." -foregroundcolor Green
        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green 
        Write-Host ""
        Write-Host "" 
}

$sInputFile= Read-Host -Prompt 'Input your EventBrite CSV file'
$sInputFile = $sInputFile.replace('"',"")
$sDefaultPassword = Read-Host -Prompt 'Input a default password for student accounts'
Create-Office365Users -sInputFile $sInputFile -sColumnName $sColumnName


Write-Host "The following users have been created:"
Write-Host "==============================================="
Write-Host $CreatedUsers


Read-Host "Press ENTER to exit"