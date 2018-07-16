enum ATEntities {
    Account
    AccountAlert
    AccountLocation
    AccountNote
    AccountTeam
    AccountToDo
    ActionType
    AdditionalInvoiceFieldValue
    AllocationCode
    Appointment
    AttachmentInfo
    BillingItem
    BillingItemApprovalLevel
    ChangeRequestLink
    ClassificationIcon
    ClientPortalUser
    Contact
    Contract
    ContractBlock
    ContractCost
    ContractExclusionAllocationCode
    ContractExclusionRole
    ContractFactor
    ContractMilestone
    ContractNote
    ContractRate
    ContractRetainer
    ContractRoleCost
    ContractService
    ContractServiceAdjustment
    ContractServiceBundle
    ContractServiceBundleAdjustment
    ContractServiceBundleUnit
    ContractServiceUnit
    ContractTicketPurchase
    Country
    Currency
    Department
    ExpenseItem
    ExpenseReport
    InstalledProduct
    InstalledProductType
    InstalledProductTypeUdfAssociation
    InternalLocation
    InventoryItem
    InventoryItemSerialNumber
    InventoryLocation
    InventoryTransfer
    Invoice
    InvoiceTemplate
    NotificationHistory
    Opportunity
    PaymentTerm
    Phase
    PriceListMaterialCode
    PriceListProduct
    PriceListRole
    PriceListService
    PriceListServiceBundle
    PriceListWorkTypeModifier
    Product
    ProductVendor
    Project
    ProjectCost
    ProjectNote
    PurchaseOrder
    PurchaseOrderItem
    PurchaseOrderReceive
    Quote
    QuoteItem
    QuoteLocation
    QuoteTemplate
    Resource
    ResourceRole
    ResourceSkill
    Role
    SalesOrder
    Service
    ServiceBundle
    ServiceBundleService
    ServiceCall
    ServiceCallTask
    ServiceCallTaskResource
    ServiceCallTicket
    ServiceCallTicketResource
    ShippingType
    Skill
    Subscription
    SubscriptionPeriod
    Task
    TaskNote
    TaskPredecessor
    TaskSecondaryResource
    Tax
    TaxCategory
    TaxRegion
    Ticket
    TicketAdditionalContact
    TicketChangeRequestApproval
    TicketChecklistItem
    TicketCost
    TicketNote
    TicketSecondaryResource
    TimeEntry
    UserDefinedFieldDefinition
    UserDefinedFieldListItem
    WorkTypeModifier
}


function Get-FieldInfo {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [Object]
        $Autotask,
        [parameter(Mandatory = $true)]
        [ATEntities[]]
        $Entity,
        [switch]
        $IncludeNonActive,
        [switch]
        $PickListOnly
    )
    begin {
    }
    process {
        $Entity | ForEach-Object {
            $ThisEntity = $_
            $Autotask.GetFieldInfo($ThisEntity) | ForEach-Object {
                $Field = $_
                $FieldItem = New-Object -TypeName PSCustomObject -Property @{
                    Name                     = $Field.Name
                    Label                    = $Field.Label
                    Type                     = $Field.Type
                    Length                   = $Field.Length
                    Description              = $Field.Description
                    IsRequired               = $Field.IsRequired
                    IsReadOnly               = $Field.IsReadOnly
                    IsQueryable              = $Field.IsQueryable
                    IsReference              = $Field.IsReference
                    ReferenceEntityType      = $Field.ReferenceEntityType
                    IsPickList               = $Field.IsPickList
                    PicklistValues           = $(
                        $Picklistvalues = $null
                        if ($Field.IsPickList) {
                            $Picklistvalues = $Field.Picklistvalues | Where-Object {$_.IsActive}
                        }
                        elseif ($IncludeNonActive) {
                            $Picklistvalues = $Field.Picklistvalues
                        }
                        if ($Picklistvalues) {
                            $Picklistvalues | ForEach-Object {
                                New-Object -TypeName PSCustomObject -Property @{
                                    Value             = $_.Value
                                    Label             = $_.Label
                                    IsDefaultValue    = $_.IsDefaultValue
                                    SortOrder         = $_.SortOrder
                                    parentValue       = $_.parentValue
                                    IsActive          = $_.IsActive
                                    IsActiveSpecified = $_.IsActiveSpecified
                                    IsSystem          = $_.IsSystem
                                    IsSystemSpecified = $_.IsSystemSpecified
                                }
                            }
                        }
                    )
                    PicklistParentValueField = $Field.PicklistParentValueField
                    DefaultValue             = $Field.DefaultValue
                }
                if ($PickListOnly -and $Field.IsPickList) {
                    $FieldItem
                }
                elseif (-not $PickListOnly) {
                    $FieldItem
                }
            }
        }
    }
    end {
    }
}
