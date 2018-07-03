#Requires -Version 5.1

# NOTICE: This only works on Windows as this relies on New-WebServiceProxy

## Use of this is an example of how to get tickets from Autotask, then to format that data
##   in a way to export to a CSV or XLSX file.
## This specific script will pull the last 60 days of tickets for the specified account
##   and it's child accounts. It will take the first 30 days of tickets and the average
##   complete(closed) tickets. After that it will do a running average of the complete
##   tickets. It will show the open and closed tickets of each day of the last 30 days
##   of tickets.


## Unused code, but a good example of how to dynamicly check if a module is installed or not,
##   then install and import it. Last line of this script shows how to export it.
## This can be used to install the ImportExcel that is required if you want to export the
##   data in a xlsx formated file.
# $Modules = @("ImportExcel")
# $Modules | ForEach-Object {
#     if (-not (Get-Module $_)) {
#         Install-Module -Name $_ -Scope CurrentUser -AllowClobber -Confirm:$false -Force
#     }
#     Import-Module $_
# }

#### Requirements ####
# # The following branch may be merged later into master
# git clone https://github.com/quonic/AutotaskCLI.git
# mkdir reports
# cd reports
# Run this script
######################

# Dot source, but in the furtur this will be published in the Powershell gallery
Get-ChildItem -Path "..\AutotaskCLI\AutotaskCLI\" -Recurse -Filter "*.ps1" | ForEach-Object {
    . $($_.FullName)
}

#### Config ####
$SearchParentCompanyName = "Customer Parent Company" # Searches for this Parent Company name
################

function Get-ConfigData {
    Param(
        $Path = "$env:TEMP\AutotaskCLI.config.xml"
    )
    if (Test-Path -Path $Path) {
        # Open Config file if exists
        $ConfigData = Import-Clixml $Path
        ## remove the following to END
        $Path = "$env:TEMP\AutotaskCLI.config.xml"
        $ConfigData = Import-Clixml $Path
        $ConfigData.LastUpdateTick = $(Get-Date).ToUniversalTime().AddHours(([TimeZoneInfo]::Local).BaseUtcOffset.Hours)
        $ConfigData.LastUpdateDate = $(Get-Date)
        Export-Clixml -Path $Path -InputObject $ConfigData
        ## END
    }
    else {
        # Create Config file if does not exists
        $ConfigData = @{
            LastUpdateTick = $(Get-Date).ToUniversalTime().AddHours(([TimeZoneInfo]::Local).BaseUtcOffset.Hours)
            LastUpdateDate = $(Get-Date)
            Credential     = $(Get-Credential -Message "Email and password for Autotask")
        }
        Export-Clixml -Path $Path -InputObject $ConfigData
    }
    return $ConfigData
}


function Get-MyCredentials {
    Param(
        [string]
        $ConfigData
    )
    if ($ConfigData.Credential) {
        # Check if creds are in config file
        return $ConfigData.Credential
    }
    else {
        # Go recreate the config file if creds aren't there.
        return (Get-ConfigData).Credential
    }
}

if ($at) {
}
else {
    $Global:ConfigData = Get-ConfigData
    $Global:Credentials = Get-MyCredentials -ConfigData $Global:ConfigData
    $Global:at = Get-AutoTaskObject -Credential $Credentials
}

# Get the PickList for Recource
# $ResourceFields = Get-FieldInfo -Autotask $at -Entity Resource -PickListOnly

# Get the Ticket Fields, but only PickLists
$TicketFields = Get-FieldInfo -Autotask $at -Entity Ticket
$Statuses = ($TicketFields | Where-Object {$_.Name -eq "Status"}).PicklistValues
$Queues = ($TicketFields | Where-Object {$_.Name -eq "QueueID"}).PicklistValues

# Create two Here-strings with C# code to create Enums
Add-Type -TypeDefinition @"
public enum E_Status
{
    `n`r$(foreach ($status in $Statuses){if($status.Value -ne 26){"`t$($status.Label.Replace(' ','').Replace('*','')) = $($status.Value)`,`n`r"}})
}
"@
Add-Type -TypeDefinition @"
public enum E_Queue
{
    `n`r$(foreach ($Queue in $Queues){if($Queue.Value -ne 26){"`t$($Queue.Label.Replace(' ','').Replace('*','')) = $($Queue.Value)`,`n`r"}})
}
"@

# Get Account Object field info
# $AccountFields = Get-FieldInfo -Autotask $at -Entity Account

$Accounts = Invoke-ATQuery -AutoTask $at -Query (ATQuery "Account" {
        Field "Active" -Equals $True
    })

# Get the Parent Account
$SelectedParentAccount = $Accounts | Where-Object {$_.AccountName -like $SearchParentCompanyName}
# Get the Parent Account and Accounts with the parent of the Parent Account
$ParentAccounts = $Accounts | Where-Object {
    ($_.id -like $SelectedParentAccount.id) -or 
    $_.ParentAccountID -eq $SelectedParentAccount.id
}

# Build the Account list part of the query
$FieldsAccountList = {
    $accts = $ParentAccounts.id
    Condition -Or {
        $accts | ForEach-Object {
            Field "AccountID" -Equals $_
        }
    }
}.Invoke()

# Create the final Query for taskfire tickets that are open from the past 60 days
$TFOpenQuery = (
    Get-Query "Ticket" {
        Field "CreateDate" -GreaterThanorEquals (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(-60)
        Field "Status" -NotEqual ([E_Status]::Complete)
        Field "QueueID" -Equals ([E_Queue]::Taskfired)
        Write-Output -InputObject $FieldsAccountList
    }
)

# Create the object that we will be using to place all results into
$Tickets = [PSCustomObject] @{
    TaskFire = [PSCustomObject] @{
        Open   = @()
        Closed = @()
    }
    Support  = [PSCustomObject] @{
        Open   = @()
        Closed = @()
    }
}

# Get all open taskfire tickets from the Taskfire queue
$Tickets.TaskFire.Open = Get-Ticket -AutoTask $at -Query $TFOpenQuery -IgnoreThresholdCheck -Verbose | Select-Object *, @{
    n = "StatusName";
    e = {$([E_Status]$($_.Status)) }
}, @{
    n = "Queue";
    e = {$([E_Queue]$($_.QueueID)) }
}, @{
    n = "AccountName";
    e = {$($accid = $_.AccountID; $Accounts | Where-Object {$_.id -eq $accid}).AccountName}
}

# Create the final Query for taskfire tickets that are closed from the past 60 days
$TFClosedQuery = (
    Get-Query "Ticket" {
        Field "CompletedDate" -GreaterThanorEquals (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(-60)
        Field "Status" -Equal ([E_Status]::Complete)
        Field "QueueID" -Equals ([E_Queue]::Taskfired)
        Write-Output -InputObject $FieldsAccountList
    }
)

# Get all closed taskfire tickets from the Taskfire queue
$Tickets.TaskFire.Closed = Get-Ticket -AutoTask $at -Query $TFClosedQuery -IgnoreThresholdCheck -Verbose | Select-Object *, @{
    n = "StatusName";
    e = {$([E_Status]$($_.Status)) }
}, @{
    n = "Queue";
    e = {$([E_Queue]$($_.QueueID)) }
}, @{
    n = "AccountName";
    e = {$($accid = $_.AccountID; $Accounts | Where-Object {$_.id -eq $accid}).AccountName}
}

# Create the final Query for Support company tickets that are open from the past 60 days
$COpenQuery = (
    Get-Query "Ticket" {
        Field "CreateDate" -GreaterThanorEquals (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(-60)
        Field "Status" -NotEqual ([E_Status]::Complete)
        Field "QueueID" -NotEqual ([E_Queue]::Taskfired)
        Write-Output -InputObject $FieldsAccountList
    }
)

# Get all open Support company tickets for the Accounts
$Tickets.Support.Open = Get-Ticket -AutoTask $at -Query $COpenQuery -IgnoreThresholdCheck -Verbose | Select-Object *, @{
    n = "StatusName";
    e = {$([E_Status]$($_.Status)) }
}, @{
    n = "Queue";
    e = {$([E_Queue]$($_.QueueID)) }
}, @{
    n = "AccountName";
    e = {$($accid = $_.AccountID; $Accounts | Where-Object {$_.id -eq $accid}).AccountName}
}

# Create the final Query for Support company tickets that are closed from the past 60 days
$CClosedQuery = (
    Get-Query "Ticket" {
        Field "CompletedDate" -GreaterThanorEquals (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(-60)
        Field "Status" -Equal ([E_Status]::Complete)
        Field "QueueID" -NotEqual ([E_Queue]::Taskfired)
        Write-Output -InputObject $FieldsAccountList
    }
)

# Get all closed Support company tickets for the Accounts
$TicketsSupportClosed = Get-Ticket -AutoTask $at -Query $CClosedQuery -IgnoreThresholdCheck -Verbose
$Tickets.Support.Closed = $TicketsSupportClosed | Select-Object *, @{
    n = "StatusName";
    e = {$([E_Status]$($_.Status)) }
}, @{
    n = "Queue";
    e = {$([E_Queue]$($_.QueueID)) }
}, @{
    n = "AccountName";
    e = {$($accid = $_.AccountID; $Accounts | Where-Object {$_.id -eq $accid}).AccountName}
}

## This can be used to diagnose what that returned or to run the report a second time after
##   changing the script below.
## WARNING: This can generate a multi GB file. 1GB ~= 100,000 tickets
# Remove-Item -Path ".\Last-60-days-Tickets.clixml"
# $Tickets | Export-Clixml -Path ".\Last-60-days-Tickets.clixml"
# $Tickets = Import-Clixml -Path ".\Last-60-days-Tickets.clixml"

"Total Tickets"
"-------------"
$TotalTicketsAll = $Tickets.Support.Closed.Count + $Tickets.Support.Open.Count + $Tickets.TaskFire.Closed.Count + $Tickets.TaskFire.Open.Count
if ($TotalTicketsAll -le 4) {
    Write-Error "Something is wrong here. TotalTicketsAll returned was less than 4."
}

# Loop inital variables
$StartDay = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(-60)
$MidDay = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(-30)
$Last60Days = $StartDay.DayOfYear..$MidDay.DayOfYear
$i = 0
Write-Progress -Activity "Last 60 Days" -PercentComplete $($i / $Last60Days.Count)
$Last60DaysAverage = $Last60Days | ForEach-Object {
    Write-Progress -Activity "Last 60 Days" -PercentComplete $($i / $Last60Days.Count)
    $i++
    $CurrentDate = (Get-Date -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays($_ - 1)
    
    $SupportCompleteTs = ($Tickets.Support.Closed | Where-Object {
            $_.CompletedDate -ge $CurrentDate -and
            $_.CompletedDate -lt $CurrentDate.AddDays(1) -and
            $_.QueueID -ne [E_Queue]::Taskfired
        }).Count
    $SupportOpenTs = ($Tickets.Support.Open | Where-Object {
            $_.CreateDate -ge $CurrentDate -and
            $_.CreateDate -le $CurrentDate.AddDays(1) -and
            $_.QueueID -ne [E_Queue]::Taskfired
        }).Count
    $TaskfiredCompleteTs = ($Tickets.TaskFire.Closed | Where-Object {
            $_.CompletedDate -ge $CurrentDate -and
            $_.CompletedDate -lt $CurrentDate.AddDays(1) -and
            $_.QueueID -eq [E_Queue]::Taskfired
        }).Count
    $TaskfiredOpenTs = ($Tickets.TaskFire.Open | Where-Object {
            $_.CreateDate -ge $CurrentDate -and
            $_.CreateDate -le $CurrentDate.AddDays(1) -and
            $_.QueueID -eq [E_Queue]::Taskfired
        }).Count
    [PSCustomObject]@{
        SupportComplete   = $SupportCompleteTs
        SupportOpen       = $SupportOpenTs
        TaskfiredComplete = $TaskfiredCompleteTs
        TaskfiredOpen     = $TaskfiredOpenTs
    }
} | Measure-Object -Property SupportComplete, SupportOpen, TaskfiredComplete, TaskfiredOpen -Average
Write-Progress -Activity "Last 60 Days" -Completed

# Loop inital variables
$FirstDay = $true
$Last30Days = $MidDay.DayOfYear..(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).DayOfYear
$RowNum = 2
$i = 0
Write-Progress -Activity "Last 30 Days" -PercentComplete $($i / $Last30Days.Count)
$Last30DaysAverage = $Last30Days | ForEach-Object {
    Write-Progress -Activity "Last 30 Days" -PercentComplete $($i / $Last30Days.Count)
    $i++
    $CurrentDate = (Get-Date -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays($_ - 1)
    if ($FirstDay) {
        # Calculate the Moving Average for Support Complete tickets
        $CompleteAvg = ($Last60DaysAverage | Where-Object {$_.Property -eq "SupportComplete"}).Average
    }

    $SupportCompleteTs = ($Tickets.Support.Closed | Where-Object {
            $_.CompletedDate -ge $CurrentDate -and
            $_.CompletedDate -lt $CurrentDate.AddDays(1) -and
            $_.QueueID -ne [E_Queue]::Taskfired
        }).Count
    $SupportOpenTs = ($Tickets.Support.Open | Where-Object {
            $_.CreateDate -ge $CurrentDate -and
            $_.CreateDate -le $CurrentDate.AddDays(1) -and
            $_.QueueID -ne [E_Queue]::Taskfired
        }).Count
    $TaskfiredCompleteTs = ($Tickets.TaskFire.Closed | Where-Object {
            $_.CompletedDate -ge $CurrentDate -and
            $_.CompletedDate -lt $CurrentDate.AddDays(1) -and
            $_.QueueID -eq [E_Queue]::Taskfired
        }).Count
    $TaskfiredOpenTs = ($Tickets.TaskFire.Open | Where-Object {
            $_.CreateDate -ge $CurrentDate -and
            $_.CreateDate -le $CurrentDate.AddDays(1) -and
            $_.QueueID -eq [E_Queue]::Taskfired
        }).Count
    if ($FirstDay) {
        [PSCustomObject]@{
            Date              = $CurrentDate.ToString("MM-dd")
            MovingAvgClosed   = $SupportCompleteTs + $CompleteAvg / 2
            SupportComplete   = $SupportCompleteTs
            SupportOpen       = $SupportOpenTs
            TaskfiredComplete = $TaskfiredCompleteTs
            TaskfiredOpen     = $TaskfiredOpenTs
        }
    }
    else {
        [PSCustomObject]@{
            Date              = $CurrentDate.ToString("MM-dd")
            MovingAvgClosed   = "=(C$RowNum+B$($RowNum-1))/2"
            SupportComplete   = $SupportCompleteTs
            SupportOpen       = $SupportOpenTs
            TaskfiredComplete = $TaskfiredCompleteTs
            TaskfiredOpen     = $TaskfiredOpenTs
        }
    }
    
    $RowNum++
    $FirstDay = $False
}
Write-Progress -Activity "Last 30 Days" -Completed

# Export the XLSX file for reviewing
#$Last30DaysAverage | Export-Excel -Path ".\ExampleReport.xlsx" -ClearSheet -AutoSize -Show