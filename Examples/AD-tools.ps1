<#


AD tools
-sanitized 

#>


#{Do/while function/loop start - this opens loop 

do 
    {
    #cls
    #{Intro header - Create CLI Menu 
    write-host ""
    Write-Host "Active Directory Tools"
    write-host ""
    #}
        #{Switch Choices - shows which numbers to press that are assigned to the switch variable
        write-host "1: AD - Find a User by Name wildcard"
        write-host "2: AD - Find a Users Group Membership"
        write-host "3: AD - Find a Users Account Expiry"
        write-host "4: AD - Find a Users Password Expiry"
        write-host "5: AD - Find a Group Name/Distrbution List by wildcard "
        write-host "6: AD - Find a Computer Account Expiry"
        write-host "7: AD - Find all Domain Controllers"
        write-host "8: AD - Find all Domain Locations and Subnets"
        write-host ""
        

            #{Switch Variarble - Path Choice Selection, prompts for choice, variable (1-6) tells the function to switch to what part of the script 
            $switch = read-host "Select Option"
            #}
         
            
            #{If/Else catch for detecting invalid selection, currently selection must be less than and gt 0 

            if(($switch -eq 1) -or ($switch -eq 2) -or ($switch -eq 3) -or ($switch -eq 4) -or ($switch -eq 5) -or ($switch -eq 6) -or ($switch -eq 7) -or ($switch -eq 8)) 
             {
            
            #($switch -lt 9) -and ($switch -gt 0)){
            
         

         
            

                    #{Switch call functions
                    Switch($switch)
                    {
                    
                    #Each number is represented from the 'menu' written above e.g 1 goes 1 below and 2 goes to 2 further done 
                    "1"
                        {
                        

                        #Function to get ad user filter wildcard etc, running a secondary/nested do/while loop
                            do
                            {
                                cls
                                    write-host "1: AD - Find a Users by Wildcard"
                                    write-host ""
                                    
                                    #prompt for variable e.g wildard string to search ad for
                                    $UserNamewildcard = Read-Host "Username" 
                                    
                                        
                                        #IF function, says if String does not equal nothing then run this function 
                                        if ($UserNamewildcard -ne "")
                                         {
                                         #creates get-ad filter searching funtion looking for wildcard strings
                                         $getADuserWildcard = Get-aduser -Filter "displayname -like '*$UserNamewildcard*'" -Properties Displayname | Select DisplayName,Name,UserPrincipalName | FT
                                            
                                            #IF Function -if the function produces nothing e.g $null it will report that nothing was found otherwise/esle it'll show the results 
                                            if
                                            ($getADuserWildcard -eq $null)
                                            {"No Results Found"}
                                            else
                                            {$getADuserWildcard}
                                                                                       
                                                                              
                                         }
                                         Else{write-host "Nothing Entered"}
                                         

                                 #creating a prompt/variable to close out the subprogram
                                 write-host ""
                                $repeatfunction1 = read-host "Run Another Query? (y/n)"

                            #Closes out the do/while loop finction, repeats with y keypress
                            }
                            while ($repeatfunction1 -eq "y")
                             

                        }
                    

                    
                    "2"
                        {
                            #another do/while subprogram loop for 2 
                            do
                            {
                                cls
                                write-host "2: AD - Find a Users Group Membership"
                                write-host ""
                                $UserName = Read-Host "Username" 

                                #{Begin If/Else to bypass Null entry e.g if nothing entered skip to else
                                if ($username -ne "")
                                    {
                                    
                                    #try/catch invalid ad user e.g if the function produces vaild results continue and show the results
                                    try
                                    {
                                    $ADgroupCN = get-aduser $UserName -Properties memberof | select memberof 
                                    $ADgroupCN.Memberof | Get-ADGroup | Select Name
                                    }

                                    #if the above function produces errors e.g invalid AD username is entered, the catch function detects the error and runs the "text" function below  
                                    catch
                                    {"No such User/Invaild Username"}

                                    }

                                Else{write-host "Nothing Entered"}
                                #}

                                write-host ""
                                $repeatfunction1 = read-host "Run Another Query? (y/n)"
                            }
                            while ($repeatfunction1 -eq "y")
                        }

                    "3"
                        {
                            do
                            {
                                cls
                                write-host "3: AD - Find User Account Expiry"
                                write-host ""
                                $UsernameExp = Read-Host "User Name" 
                                
                                #try/catch start
                                try 
                                {

                                $Expirydate = Get-aduser $UsernameExp -Properties Accountexpirationdate


                               

                                      
                               
                                            if ($Expirydate.accountexpirationdate -eq $null)
                                                {write-host ""
                                                write-host "Never expires"}
                                            else
                                                {write-host ""
                                                Write-host "Expires" $Expirydate.accountexpirationdate}
                                      
                                     
                                }
                                Catch
                                 {"No such User"}   


                                write-host ""
                                $repeatfunction4 = read-host "Run Another Query? (y/n)"
                            }
                            while ($repeatfunction4 -eq "y")
                        }
                    "4"
                        {
                            do
                            {
                                cls
                                write-host "4: AD - Find User Account Password Expiry"
                                write-host ""
                                $UsernamePWExp = Read-Host "User Name" 

                                if ($UsernamePWExp -ne "")
                                    {
                                        #{Try/Catch, Try for vaild username, catch errors for no user exists, spelling mistakes etc
                                        try
                                            {
                                            $pwexp = Get-ADUser $usernamepwexp -Properties msDS-UserPasswordExpiryTimeComputed, PasswordLastSet, CannotChangePassword, UserPrincipalName
                                           
                                           #Piping a property and renaming the name of the property to something more relatable, also modifying the expression of the propertys result e.g converting timestring to Datetime format

                                            $pwexp | select @{Name="Username";Expression={$_.Name}}, @{Name="Password Expiry Date";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, @{Name="Password Last Set";Expression={$_.PasswordLastSet}} | fl
                                            }
                                        Catch
                                        {"No such User"}
                                        #}
                                    }
                                Else{write-host "Null Response"}

                                write-host ""
                                $repeatfunction4 = read-host "Run Another Query? (y/n)"
                            }
                            while ($repeatfunction4 -eq "y")
                        }


                    "5"
                        {
                        do
                            {
                            cls
                            write-host "5: AD - Search for Group Name"
                            write-host ""
                            $ADGroupKeyword = read-host "Keyword"

                                if ($ADgroupkeyword -ne "")
                                    {
                                    Get-ADGroup -Filter "name -like '*$ADGroupKeyword*'" | Select name
                                    }


                                Else{write-host "Null Response"}

                            write-host ""
                            $RepeatFunction2 = read-host "Run Another Query? (y/n)"
                            }
                            while ($RepeatFunction2 -eq "y")
                        }

                    "6"
                        {
                            do
                            {
                                cls
                                write-host "6: AD - Find Machine Account Expiry"
                                write-host ""
                                $Computername = Read-Host "Computer Name" 
                                
                                
                                    if ($computername -ne "")
                                        {
                                        $Accountexpstring = Get-ADComputer $Computername -Properties accountexpires
                                            #{If/Else queries, if AccountExpiry equals string for never, Else convert string to date

                                            if ($Accountexpstring.accountexpires -eq "9223372036854775807")
                                                {write-host ""
                                                write-host "Never expires"}
                                            else
                                                {[datetime]$Accountexpstring.accountexpires}
                                            #}
                                        }
                                    Else{write-host "Null Response"}       

                                write-host ""
                                $repeatfunction3 = read-host "Run Another Query? (y/n)"
                            }
                            while ($repeatfunction3 -eq "y")
                        }


                    "7"
                        {
                            
                          
                                cls
                                write-host "7: AD - Find all Domain Controllers"
                                write-host ""

                                $AllDCs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }
                                $AllDCs.name
                        }


                    "8"
                        {
                            
                            do
                              {

                                

                                cls
                                write-host "8: AD - Find all Domain Locations and Subnets"
                                write-host ""

                                Get-ADReplicationSubnet -Filter * | select Location -Unique | Sort location | ft

                                write-host ""
                                

                                $Site = Read-Host "Which Site's Subnet are you looking for?"

                                try{

                                $subnet = Get-ADReplicationSubnet -Filter "location -like '*$Site*'" | select Location,Name | Sort Location

                            
                                if ($subnet -ne $null)
                                {
                                write-host ""
                                $subnet}
                                else{
                                write-host ""
                                "Location Not Found"}
                     
                                }
                                Catch
                                {""
                                "Nothing Entered"
                                }

                                write-host ""
                                $RepeatFunction2 = read-host "Run Another Query? (y/n)"
                              }
                              while ($RepeatFunction2 -eq "y")
                               
                        }


#Close out repeat loop

                    }


                    #}

    #{Repeat Program Selection Variable
    write-host ""
    $repeat = Read-Host "Return to main menu? (y/n)"

    #}


                 }
    Else
    {
    write-host ""
    write-host "Invalid Selection"
    write-host ""
    $repeat = "y"
    }


    }

            

while ($repeat -eq "y")
#}
""
"Exiting"
 