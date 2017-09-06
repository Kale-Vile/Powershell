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
 
$emailusername = "########@#####\email address"
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


$AADPGroupID = "######"
$AADDPGroup = Get-MsolGroup -ObjectId $AADPGroupID
$MFAGroup = Get-MsolGroupMember -GroupObjectId $AADPGroupID 

$UPN = $args[0]

$MFA = if ($MFAGroup.emailaddress -contains "$upn")
{"$FN $LN has MFA required"}
else
{"$FN $LN has MFA disabled"}

$MFAEnrolled = if($user.StrongAuthenticationMethods -ne $null )
{"a device enrolled"}
else
{"no device enrolled"}

"$MFA and $MFAEnrolled"

}
else
{"Invalid User"}

} -ArgumentList $Testpass,$credential

Wait-Job $job | Out-Null
Receive-Job $job 