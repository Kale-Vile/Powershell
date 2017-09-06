<#



Sanitized
AD count and email


#>

#Set Time/Environment

$date = Get-Date 
$monthago = $date.AddMonths(-1)
$dateconverted = $date.ToString('dd-MMM-yy')
$monthagoconverted = $monthago.ToString('dd-MMM-yy')
$Justmonth = $monthago.ToString("MMMMMM")
$Startfolder = "D:\Scripts\EOM-Reporting\"


#Build SPN AD-Group Array

$spnusergroups = 
"########",
"########",

#Get AD-users members from the AD-Groups in the Array 

$collectspnuser = $spnusergroups | ForEach-Object {Get-ADGroupMember "$_"} | Select name

#Harvest extra Ad-User details required for filtering -eg Name,Company,Lastlogondate 

$spnusers = $collectspnuser |  ForEach-Object {Get-ADUser -Identity $_.name -Properties name,company,lastlogondate} | Select Name,Company,lastlogondate | Sort name  

#Run filtering via where-object (Filter -Username begins With ###)

$filteredspnusers = $spnusers | Where-Object {($_.Name -like "#*") -or ($_.Name -like "####*") -or ($_.Name -like "###*") -and ($_.Company -ne "###########################") -and ($_.lastlogondate -gt "$monthago")} 

#filter results to unique users only -eg remove duplicates of users in multiple SPN groups 

$uniquefilteredspnusers = $filteredspnusers | Select Name -Unique
$filteredADSPNusers = $uniquefilteredspnusers | ForEach-Object {Get-ADUser -Identity $_.name -Properties name,company,lastlogondate} | Select Name,Company,lastlogondate

#get All AD total users, filtered to lastlogondate >1 month and not ###### company name  

$getADusers = get-aduser -filter {(Company -ne "##########") -and (lastlogondate -gt $monthago)} -Properties lastlogondate,Company | select Name,LastLogonDate,Company | sort name 

$filterADusers = $getADusers | Where-Object {($_.Name -like "#*") -or ($_.Name -like "##*") -or ($_.Name -like "###*") -and ($_.Name -notlike "###*") -and ($_.Name -notlike "###*")} 


#Console CLI Output


cls
write-host ""
write-host ""
write-host ""
Write-host "Users counted from the below SPN groups:" -BackgroundColor DarkGreen
write-host ""
$spnusergroups
write-host ""
Write-host "Date Range:" -BackgroundColor DarkGreen
write-host ""
Write-Host "$monthagoconverted -> $dateconverted"
write-host ""
write-host "SPN User Count (Filtered SPN Groups, Date Range, Username begins With ######,### & Company does not equal #####):" -BackgroundColor DarkGreen
write-host ""
$uniquefilteredspnusers.Count
$totalspnusers = $uniquefilteredspnusers.Count
write-host ""
write-host "AD User Count (Filtered Date Range,Username begins With ######,#### & Company does not equal #####)" -BackgroundColor DarkGreen
write-host ""
$filterADusers.count
$totalADuser = $filterADusers.count
write-host ""

#Export User Arrays to CSV

$filteredADSPNusers | Export-Csv E:\SPNUserTest.csv -NoTypeInformation
$filterADusers| Export-Csv E:\ADUserTest.csv -NoTypeInformation

#Build SPN Group CSV (foreach array to line function)

$spngroupfilename = $Startfolder+"SPNGroup-"+$dateconverted+".csv"

if (Test-Path $spngroupfilename -ne $null)

{Remove-Item -Path $spngroupfilename}


##Add title


Remove-Item -Path $spngroupfilename
$csv =@"
"SPN Group",
"@
$csv >>E:\SPNGroups.csv

##add foreach into csv

$spnusergroups | foreach {
$csv =@"
 $_,
"@
$csv >>e:\SPNGroups.csv
}

##Format Csv 

$csvImport = Import-Csv E:\SPNGroups.csv
$csvimport | Export-Csv E:\SPNGroups.csv -NoTypeInformation

#Build Filter info CSV

$queryparamfilename = $Startfolder+"QueryParameter-"+$dateconverted+".csv"

if (Test-Path $queryparamfilename -ne $null)

{Remove-Item -Path $queryparamfilename}

$csvfilter = @"
"Logon Date Range:","$monthagoconverted to $dateconverted"
"SPN Filter:", "Filtered by SPN Group Membership, Logon Date Range, Username begins With ##,##,## and Company Name is not #######"
"AD Filter:", "Filtered by Date Range, Username begins With ###,###,## and Company Name is not ######"
"@
$csvfilter >>$queryparamfilename 

$csvImport = Import-Csv $queryparamfilename
$csvimport | Export-Csv $queryparamfilename -NoTypeInformation

#Send Email

           
            $body="<!DOCTYPE html>"
            $body+="<HTML>"
            $body+="<body>"
            $body+="<p style=`"color:black; font-family:calibri; font-size:11pt;`">Hello,</p>"
            $body+="<p style=`"color:black; font-family:calibri; font-size:11pt;`">Month End SPN and AD users Count for $Justmonth; </p>"
            $body+="<p style=`"color:black; font-family:calibri; font-size:11pt;`"> SPN User Count: <span style=`"color:black; font-family:calibri; font-size:11pt;;font-weight:bold`"> $totalspnusers </span>   </p>"
            $body+="<p style=`"color:black; font-family:calibri; font-size:11pt;`"> </p>"
            $body+="<p style=`"color:black; font-family:calibri; font-size:11pt;`">AD User Count: <span style=`"color:black; font-family:calibri; font-size:11pt;;font-weight:bold`"> $totalADuser </span> </p>"
            $body+="<p style=`"color:black; font-family:calibri; font-size:11pt;`"> Regards, </p>"
            $body+="<hr>"
            $body+="<span style=`"color:red; font-family:arial; font-size:12pt;`"><b>Automated Script</b></span><br>"
            $body+="<span style=`"color:black; font-family:arial; font-size:10pt;`">#########<br></span>"
            $body+="<span style=`"color:black; font-family:arial; font-size:8pt;`">####<br>"
            send-mailmessage -From "######@####.COM" -subject "Month End SPN and AD users Count for $Justmonth " -To "########@#####.com.au" -Attachments "E:\ADUserTest.csv","E:\SPNUserTest.csv","E:\SPNGroups.csv","$queryparamfilename" -smtpserver "############" -body "$body" -BodyAsHtml
        
        
