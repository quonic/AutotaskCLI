function Get-Query {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Catagory,

        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [scriptblock]
        $ChildItem
    )
    
    begin {
    }
    
    process {
        $sbString = "
        queryxml {
            version = `"1.0`"
            entity {
                `'$Catagory`'
            }
            query {
                $($ChildItem | ForEach-Object { $_.Invoke() })
            }
        }"
        $scriptB = [ScriptBlock]::Create($sbString)
        [System.Xml.Linq.XElement]$Xml = New-XmlDocument -ScriptBlock $scriptB
        try {
            
        }
        catch {
            throw "Field is not formated correctly, see Get-Help New-XmlDocument."
        }
    }
    
    end {
        return $Xml.ToString()
    }
}

function Get-Condition {
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([string])]
    param (
        [Parameter(
            
            Position = 0,
            ParameterSetName = "AndSet"
        )]
        [switch]
        $And,
        [Parameter(
            
            Position = 0,
            ParameterSetName = "OrSet"
        )]
        [switch]
        $Or,
        [Alias("Condition")]
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [Parameter(ParameterSetName = "AndSet")]
        [Parameter(ParameterSetName = "OrSet")]
        [scriptblock]
        $ChildItem
    )
    
    begin {
    }
    
    process {
        $Op = "AND"
        if ($Or) {
            $Op = "OR"
        }
        $sbString = "
            condition{
                operator = `"$Op`"
                $($ChildItem | ForEach-Object { $_.Invoke() })
            }"
    }
    
    end {
        return $sbString
    }
}

function Get-Field {
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([string])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "EqualsSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "NotEqualSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "GreaterThanSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "LessThanSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "GreaterThanorEqualsSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "LessThanOrEqualsSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "BeginsWithSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "EndsWithSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "ContainsSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "IsNotNullSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "IsNullSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "IsThisDaySet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "LikeSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "NotLikeSet")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "SoundsLikeSet")]
        [ValidateNotNullOrEmpty()]
        [String]
        $Property,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "EqualsSet")][switch][Alias("eq")]$Equals,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "NotEqualSet")][switch][Alias("ne")]$NotEqual,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "GreaterThanSet")][switch][Alias("gt")]$GreaterThan,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "LessThanSet")][switch][Alias("lt")]$LessThan,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "GreaterThanorEqualsSet")][switch][Alias("ge")]$GreaterThanorEquals,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "LessThanOrEqualsSet")][switch][Alias("le")]$LessThanOrEquals,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "BeginsWithSet")][switch][Alias("begin")]$BeginsWith,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "EndsWithSet")][switch][Alias("end")]$EndsWith,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "ContainsSet")][switch]$Contains,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "IsNotNullSet")][switch][Alias("nn")]$IsNotNull,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "IsNullSet")][switch][Alias("in")]$IsNull,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "IsThisDaySet")][switch][Alias("td")]$IsThisDay,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "LikeSet")][switch]$Like,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "NotLikeSet")][switch]$NotLike,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "SoundsLikeSet")][switch][Alias("sounds")]$SoundsLike,
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "EqualsSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "NotEqualSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "GreaterThanSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "LessThanSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "GreaterThanorEqualsSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "LessThanOrEqualsSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "BeginsWithSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "EndsWithSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "ContainsSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "IsNotNullSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "IsNullSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "IsThisDaySet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "LikeSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "NotLikeSet")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "SoundsLikeSet")]
        [String]
        $Value,
        # Expects Property, Value, and Operator as properties
        [Parameter(ParameterSetName = "InputObjectSet")]
        [Parameter(ValueFromPipeline = $true)]
        [PSObject]
        $InputObject
        # [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "ScriptBlockSet")]
        # [ScriptBlock]
        # $Filter
    )
    
    begin {
        $binaryOperator = $null
        
        if ($Equals) {
            $binaryOperator = "Equals"
        }
        elseif ($NotEqual) {
            $binaryOperator = "NotEqual"
        }
        elseif ($GreaterThan) {
            $binaryOperator = "GreaterThan"
        }
        elseif ($LessThan) {
            $binaryOperator = "LessThan"
        }
        elseif ($GreaterThanorEquals) {
            $binaryOperator = "GreaterThanorEquals"
        }
        elseif ($LessThanOrEquals) {
            $binaryOperator = "LessThanOrEquals"
        }
        elseif ($BeginsWith) {
            $binaryOperator = "BeginsWith"
        }
        elseif ($EndsWith) {
            $binaryOperator = "EndsWith"
        }
        elseif ($Contains) {
            $binaryOperator = "Contains"
        }
        elseif ($IsNotNull) {
            $binaryOperator = "IsNotNull"
        }
        elseif ($IsNull) {
            $binaryOperator = "IsNull"
        }
        elseif ($IsThisDay) {
            $binaryOperator = "IsThisDay"
        }
        elseif ($Like) {
            $binaryOperator = "Like"
        }
        elseif ($NotLike) {
            $binaryOperator = "NotLike"
        }
        elseif ($SoundsLike) {
            $binaryOperator = "SoundsLike"
        }
        
    }
    
    process {
        $Field = ""
        $ProcessInputObject = $false
        if ($InputObject) {
            [string]$Field = $InputObject.Property
            [string]$Value = $InputObject.Value
            [string]$binaryOperator = $InputObject.Operator
            $ProcessInputObject = $true
        }
        elseif ($Property -and $Value) {
            [string]$Field = $Property
        }
        else {
            [string]$Field = $Property
            $Value = ""
        }
        $sbString = "
        field {
            `'$Field`'
            expression {
                op = $binaryOperator
                `'$Value`'
            }
        }"
    }
    
    end {
        return $sbString
    }
}

<#
.SYNOPSIS
Invoke query() from Autotask API

.DESCRIPTION
Invoke query() from Autotask API

.PARAMETER AutoTask
The Autotask object from Get-AutoTaskObject

.PARAMETER Query
Filter built from New-Query, (New-Condition, and/or New-Field)

.EXAMPLE
Invoke-ATQuery -AutoTask (Get-AutoTaskObject) -Query (
    New-Query -Catagory "Ticket" -Field (
        New-Field -Property "TicketNumber" -Equals -Value "T19010101.0000"))

.EXAMPLE
Invoke-ATQuery -AutoTask (Get-AutoTaskObject) -Query (
    New-Query -Catagory "Ticket" -Condition (
        New-Condition -And -Field @(
            (New-Field -Property "LastActivityDate" -GreaterThan -Value (Get-Date)),
            (New-Field -Property "AccountID" -Equals -Value "1234")
        )))

.NOTES
General notes
#>
function Invoke-ATQuery {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(ParameterSetName = "TicketSet")]
        [Object]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $AutoTask,
        [string]
        $Query
    )
    
    begin {
        $response = $AutoTask.query($Query)
    }
    
    end {
        Write-Verbose -Message "Return Code:$($response.ReturnCode)"
        Write-Verbose -Message "Count:$($response.EntityResults.Count)"
        if ($response.ReturnCode -ne 1) {
            return $response
        }
        if ($response.EntityResults.Count -eq 0) {
            return $response
        }
        if ($response.EntityResults.Count -eq 500) {
            Write-Verbose -Message "Returned 500 results. TODO: write code to handle getting the other data"
            # TODO: write code to handle getting the other data
            #  To query for additional records over the 500 maximum for a given set of search criteria, repeat the query and filter by id value > the previous maximum id value retrieved.
            return $response
        }
        else {
            return $response.EntityResults
        }
        
    }
}
New-Alias -Name "Query" -Value "Get-Query" -Force -Scope Global -Option ReadOnly