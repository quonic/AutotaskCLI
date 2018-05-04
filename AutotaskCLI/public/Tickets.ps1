
function Get-Ticket {
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([bool], [string], [object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object]
        $AutoTask,
        [Parameter(ParameterSetName = "TicketNumberSet")]
        #[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
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
        [Parameter(ParameterSetName = "TicketIDSet")]
        [string[]]
        $TicketID,
        [Parameter(ParameterSetName = "QuerySet")]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Query,
        [string]
        $Status
    )
    
    begin {
        # Check if we can Query for tickets
        if (-not ($AutoTask.getEntityInfo() | Where-Object {$_.Name -like "Ticket"}).CanQuery) {
            throw "You do not have Query permissions for Tickets."
        }
    }
    
    process {
        if ($Query) {
            # Query base on provided Query
            Invoke-ATQuery -AutoTask $AutoTask -Query $Query
        }
        elseif ($TicketNumber) {
            # Get the ticket based on the Ticket number
            Invoke-ATQuery -AutoTask $AutoTask -Query (
                Get-Query "Ticket" {
                    $TicketNumber | ForEach-Object {
                        Get-Field -Property "TicketNumber" -Equals -Value $_
                    }
                })
        }
        elseif ($TicketID) {
            Invoke-ATQuery -AutoTask $AutoTask -Query (
                Get-Query "Ticket" {
                    if ($Status) {
                        Get-Field -Property "Status" -Equals -Value $Status
                    }
                    $TicketID | ForEach-Object {
                        Get-Field -Property "id" -Equals -Value $_
                    }
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
    [OutputType([Object], [bool])]
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
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
    }
    
    process {

        if ($PSCmdlet.ShouldProcess($Title)) {
            $Namespace = $AutoTask.GetType().Namespace
            #$ATWSResponse = New-Object ($Namespace + ".ATWSResponse")
            $Ticket = New-Object ($Namespace + ".Ticket")
        
            $Ticket.DueDateTime = $DueDateTime
            $Ticket.Status = $Status
            $Ticket.Title = $Title
            $Ticket.Priority = $Priority
            $Ticket.AccountID = $AccountID

        
            if ($IssueType) {
                $Ticket.IssueType = $IssueType
            }
            if ($SubIssueType) {
                $Ticket.SubIssueType = $SubIssueType
            }
            if ($TicketCategory) {
                $Ticket.TicketCategory = $TicketCategory
            }
            if ($TicketType) {
                $Ticket.TicketType = $TicketType
            }
            if ($Description) {
                $Ticket.Description = $Description
            }
            if ($QueueID) {
                $Ticket.QueueID = $QueueID
            }
            if ($Source) {
                $Ticket.Source = $Source
            }
            if ($Fields) {
                $Ticket.Fields = $Fields
            }
            if ($UserDefinedFields) {
                $Ticket.UserDefinedFields = $UserDefinedFields
            }
            if ($AllocationCodeID) {
                $Ticket.AllocationCodeID = $AllocationCodeID
            }
            if ($AssignedResourceID) {
                $Ticket.AssignedResourceID = $AssignedResourceID
            }
            if ($AssignedResourceRoleID) {
                $Ticket.AssignedResourceRoleID = $AssignedResourceRoleID
            }
            if ($ChangeApprovalBoard) {
                $Ticket.ChangeApprovalBoard = $ChangeApprovalBoard
            }
            if ($ChangeApprovalStatus) {
                $Ticket.ChangeApprovalStatus = $ChangeApprovalStatus
            }
            if ($ChangeApprovalType) {
                $Ticket.ChangeApprovalType = $ChangeApprovalType
            }
            if ($ChangeInfoField1) {
                $Ticket.ChangeInfoField1 = $ChangeInfoField1
            }
            if ($ChangeInfoField2) {
                $Ticket.ChangeInfoField2 = $ChangeInfoField2
            }
            if ($ChangeInfoField3) {
                $Ticket.ChangeInfoField3 = $ChangeInfoField3
            }
            if ($ChangeInfoField4) {
                $Ticket.ChangeInfoField4 = $ChangeInfoField4
            }
            if ($ChangeInfoField5) {
                $Ticket.ChangeInfoField5 = $ChangeInfoField5
            }
            if ($ContactID) {
                $Ticket.ContactID = $ContactID
            }
            if ($ContractID) {
                $Ticket.ContractID = $ContractID
            }
            if ($ContractServiceBundleID) {
                $Ticket.ContractServiceBundleID = $ContractServiceBundleID
            }
            if ($ContractServiceID) {
                $Ticket.ContractServiceID = $ContractServiceID
            }
            if ($EstimatedHours) {
                $Ticket.EstimatedHours = $EstimatedHours
            }
            if ($ExternalID) {
                $Ticket.ExternalID = $ExternalID
            }
            if ($InstalledProductID) {
                $Ticket.InstalledProductID = $InstalledProductID
            }
            if ($OpportunityId) {
                $Ticket.OpportunityId = $OpportunityId
            }
            if ($ProblemTicketId) {
                $Ticket.ProblemTicketId = $ProblemTicketId
            }
            if ($ProjectID) {
                $Ticket.ProjectID = $ProjectID
            }
            if ($PurchaseOrderNumber) {
                $Ticket.PurchaseOrderNumber = $PurchaseOrderNumber
            }
            if ($Resolution) {
                $Ticket.Resolution = $Resolution
            }
            if ($ServiceLevelAgreementID) {
                $Ticket.ServiceLevelAgreementID = $ServiceLevelAgreementID
            }
            
            
            $TicketArray = $Ticket | ForEach-Object {
                New-Object ($Namespace + ".Ticket") -ArgumentList $_
            }
            
            $entityArray = New-Object ($Namespace + ".Entity") -ArgumentList $TicketArray
            
            $Response = $AutoTask.Create($entityArray)
            
            if ($Response.ReturnCode -eq 1) {
                return $true
            }
            else {
                $Response
                return $false
            }
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