enum TimeEntryType {
    ITServiceRequest = 2 # TicketID
    ProjectTask = 6 # TaskID

}

function New-TimeEntry {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool], [string], [object])]
    param (
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        #[Object]
        [Object]
        $AutoTask,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)][datetime]$DateWorked, #Required
        #[Parameter(Mandatory, ValueFromPipelineByPropertyName)][int]$id, # Read only
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)][Alias("Resource")][int]$ResourceID,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)][Alias("Role")][int]$RoleID,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)][TimeEntryType]$Type, #PickList
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)]                                [datetime]$BillingApprovalDateTime,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)]                                [datetime]$EndDateTime,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)]                                [datetime]$StartDateTime,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][ValidateRange(0, 24)]          [double]$HoursWorked,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)]                                [switch]$NonBillable,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)]                                [double]$OffsetHours,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)]                                [switch]$ShowOnInvoice,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][ValidateLength(0, 8000)]       [string]$InternalNotes,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][ValidateLength(0, 8000)]       [string]$SummaryNotes,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][Alias("Task")]                 [int]$TaskID,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][Alias("Ticket")]               [int]$TicketID,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][Alias("BillingResource")]      [int]$BillingApprovalResourceID,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][Alias("Contract")]             [int]$ContractID,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][Alias("AllocationCode")]       [int]$AllocationCodeID,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][Alias("InternalAllocationCode")]       [int]$InternalAllocationCodeID,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][Alias("ContractService")]      [int64]$ContractServiceID,
        [Parameter(ParameterSetName = "NewTimeEntryNotRequiredSet", ValueFromPipelineByPropertyName)][Alias("ContractServiceBundle")][int64]$ContractServiceBundleID
        #[int]$BillingApprovalLevelMostRecent,# Read only
        #[datetime]$CreateDateTime,# Read only
        #[int]CreatorUserID,# Read only
        #[double]$HoursToBill,# Read only
        #[datetime]$LastModifiedDateTime,# Read only
        #[int]$LastModifiedUserID,# Read only


    )
    
    begin {
        # TODO: make this work
        
        # Do not use as is
        throw "Don't call this as it isn't working"
        # All datetimes are in EST
        $DateWorked = $DateWorked.ToUniversalTime().AddHours(-5)
        if ($BillingApprovalDateTime) {$BillingApprovalDateTime = $BillingApprovalDateTime.ToUniversalTime().AddHours(-5)}
        if ($EndDateTime) {$EndDateTime = $EndDateTime.ToUniversalTime().AddHours(-5)}
        if ($StartDateTime) {$StartDateTime = $StartDateTime.ToUniversalTime().AddHours(-5)}
        [int]$id = 0
        if ($EndDateTime -le $StartDateTime) {
            throw "EndDateTime must be greater than StartDateTime"
        }
        #$InternalAllocationCode
        #"InternalActivity"
        $Roles = Invoke-ATQuery -AutoTask $AutoTask -Query $(
            Get-Query "Role" {
                Get-Field -Property "Active" -Equals -Value $true
            })
        $AppSpec = $Roles | Where-Object {$_.Name -like "Application Specialist"}
        $AutoTask = Get-AutoTaskObject
        $Resource = Get-ATUser -AutoTask $AutoTask -FirstName 'Bob' -LastName 'Doel'
        if ($pscmdlet.ShouldProcess($computername)) {
            $AppSpec.id
            $Resource.id
        }
    }
    
    process {
    }
    
    end {
        return $true
    }
}