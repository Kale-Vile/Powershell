<#

Bulk ping script for testing connection to a number of devices

#>


$Content = read-host "Enter .txt or .csv path with list computer name or IP's to test (eg. C:\ping.txt)"

$names = Get-content $content 

foreach ($name in $names)

{

$testconnection = Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue

if ($testconnection)

{Write-Host "$name ping success" -ForegroundColor Green}

else

{Write-Host "$name ping failed" -ForegroundColor Red}

}