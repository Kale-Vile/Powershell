<#
    
   ____              __          
  /  _/__ _  _____  / /_____ ____
 _/ // _ \ |/ / _ \/  '_/ -_) __/
/___/_//_/___/\___/_/\_\\__/_/   
                                 

Invokation Script 
-Check/call for creds
-Foreach Invoker for a basic AD function, can be replaced with another function  
-PS Session run as
-PSobject/Custom array built 
                                        
#>

$results = @()


if ($Credential.UserName -eq $null)
{
$ADMuser = Read-host "Admin Username"
$securepass=Read-Host "Enter the password" -AsSecureString
$Credential = New-Object System.Management.Automation.PSCredential $ADMUser, $SecurePass
""
}



Get-PSSession #| Remove-PSSession

"Credentials"
$Credential

$Session = Get-PSSession 
if ($Session.Name -ne "AD")
{
$ADserver = Read-Host "Enter Domain Controller Name"
$ADSession = New-PSSession -ComputerName $ADserver -Credential $Credential -Name AD
}





do
{
sleep 1
}

while ($ADSession.State -ne "Available") 


$usertxt = read-host "Enter pathto .txt file with users to be scanned" 
$Content = Get-Content $usertxt
""


foreach ($username in $Content)
{



$invoke = Invoke-Command -Session $ADSession {get-aduser $args[0]} -args $username

$results+=$invoke 


}



$results