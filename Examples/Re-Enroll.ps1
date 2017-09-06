  param(
    [Parameter(Mandatory)]
    [ValidateScript({
      If ($_ -match @"
^[a-zA-Z0-9.!£#$%&'^_`{}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$
"@) {
        $True
      }
      else {
        Throw "$_ is an invalid email address"
      }
    })]
    [string]$testpass
  )
 

$emailusername = "##@###.#####/email"
$encrypted = Get-Content C:\########\encrypted_password.txt | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($emailusername, $encrypted)

$job = Start-job  {
Connect-MsolService -Credential $args[1]
$user = Get-MsolUser -UserPrincipalName $args[0]
if($user -ne $null )
{
$FN = $user.FirstName
$LN = $user.LastName
$Enforced = Get-msoluser -UserPrincipalName $args[0] | Select-Object -ExpandProperty StrongAuthenticationRequirements
$EnforceState = $Enforced.State

$AADPGroupID = "################"
$AADDPGroup = Get-MsolGroup -ObjectId $AADPGroupID
$MFAGroup = Get-MsolGroupMember -GroupObjectId $AADPGroupID 

$UPN = $args[0]


"Removing enrolled device"

Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationMethods @() 

sleep 1

$REcheck = Get-MsolUser -UserPrincipalName $UPN

$MFAEnrolled = if($REcheck.StrongAuthenticationMethods -ne $null )
{"Failed to remove enrolled device"}
else
{"MFA is ready to re-enroll a Device"}
 
$MFAEnrolled

}
else
{"Invalid User"}

} -ArgumentList $Testpass,$credential

Wait-Job $job | Out-Null
Receive-Job $job 
