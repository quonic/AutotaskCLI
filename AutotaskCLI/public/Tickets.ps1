
function Get-Ticket {
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([bool], [string], [object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object]
        $AutoTask,
        [Parameter(ParameterSetName = "TicketNumberSet")]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                If ($_ -match 'T[0-9]{8}.[0-9]{4}.[0-9]{3}|T[0-9]{8}.[0-9]{4}') {
                    $True
                }
                else {
                    Throw "$_ is not a valid ticket number. Correct ticket number format is T00000000.0000 or T00000000.0000.000 "
                }
            })]
        [string]
        $TicketNumber,
        [Parameter(ParameterSetName = "QuerySet")]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Query
    )
    
    begin {
        if (-not ($AutoTask.getEntityInfo() | Where-Object {$_.Name -like "Ticket"}).CanQuery) {
            throw "You do not have Query permissions for Tickets."
        }
    }
    
    process {
        if ($Query) {
            Invoke-ATQuery -AutoTask $AutoTask -Query $Query
        }
        elseif ($TicketNumber) {
            Invoke-ATQuery -AutoTask $AutoTask -Query $(
                Query "Ticket" {
                    Field -Property "TicketNumber" -Equals -Value $TicketNumber
                })
        }
        else {
            throw "Query and TicketNumber where not defined."
        }
    }
    
    end {
    }
}

function New-Ticket {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Medium'
    )]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object]
        $AutoTask,
        [Parameter(ValueFromPipelineByPropertyName)][int64]$id = 0,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)][DateTime]$DueDateTime,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)][int]$Status,
        [ValidateLength(0, 255)][Parameter(Mandatory, ValueFromPipelineByPropertyName)][string]$Title,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)][int]$Priority,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)][int]$AccountID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$IssueType,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$SubIssueType,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$TicketCategory,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$TicketType,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][ValidateLength(0, 8000)][Parameter(ValueFromPipelineByPropertyName)][string]$Description,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$QueueID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$Source,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][AutoTask.Field[]]$Fields,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][Autotask.UserDefinedField[]]$UserDefinedFields,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$AllocationCodeID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$AssignedResourceID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$AssignedResourceRoleID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$ChangeApprovalBoard,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$ChangeApprovalStatus,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$ChangeApprovalType,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][ValidateLength(0, 8000)][Parameter(ValueFromPipelineByPropertyName)][string]$ChangeInfoField1,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][ValidateLength(0, 8000)][Parameter(ValueFromPipelineByPropertyName)][string]$ChangeInfoField2,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][ValidateLength(0, 8000)][Parameter(ValueFromPipelineByPropertyName)][string]$ChangeInfoField3,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][ValidateLength(0, 8000)][Parameter(ValueFromPipelineByPropertyName)][string]$ChangeInfoField4,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][ValidateLength(0, 8000)][Parameter(ValueFromPipelineByPropertyName)][string]$ChangeInfoField5,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$ContactID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$ContractID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int64]$ContractServiceBundleID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int64]$ContractServiceID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][Double]$EstimatedHours,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][ValidateLength(0, 50)][Parameter(ValueFromPipelineByPropertyName)][String]$ExternalID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$InstalledProductID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$OpportunityId,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$ProblemTicketId,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$ProjectID,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][ValidateLength(0, 50)][Parameter(ValueFromPipelineByPropertyName)][string]$PurchaseOrderNumber,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][ValidateLength(0, 3200)][Parameter(ValueFromPipelineByPropertyName)][string]$Resolution,
        [Parameter(ParameterSetName = "NewTicketNotRequiredSet")][Parameter(ValueFromPipelineByPropertyName)][int]$ServiceLevelAgreementID
        # if InstalledProductID is populated, the InstalledProduct.AccountID must = Ticket.AccountID
        # Priority must be an active priority.
        # AllocationCodeID is required on create() and update() if your company has enabled the Autotask system setting that requires a Work Type on a Ticket.
    )
    
    begin {
        if (-not ($AutoTask.getEntityInfo() | Where-Object {$_.Name -like "Ticket"}).CanCreate) {
            throw "You do not have Create permissions for Tickets."
        }
    }
    
    process {
        if ($pscmdlet.ShouldProcess($Title)) {
            
        }
    }
    
    end {
    }
}

function Update-Ticket {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Medium'
    )]
    param (
        [Parameter(ParameterSetName = "TicketNumberSet")]
        [Parameter(ParameterSetName = "QuerySet")]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object]
        $AutoTask,
        [Parameter(ParameterSetName = "TicketNumberSet")]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                If ($_ -match 'T[0-9]{8}.[0-9]{4}.[0-9]{3}|T[0-9]{8}.[0-9]{4}') {
                    $True
                }
                else {
                    Throw "$_ is not a valid ticket number. Correct ticket number format is T00000000.0000 or T00000000.0000.000 "
                }
            })]
        [string]
        $TicketNumber
    )
    
    begin {
        if (-not ($AutoTask.getEntityInfo() | Where-Object {$_.Name -like "Ticket"}).CanUpdate) {
            throw "You do not have Create permissions for Tickets."
        }
    }
    
    process {
        if ($pscmdlet.ShouldProcess($TicketNumber)) {
            
        }
    }
    
    end {
    }
}