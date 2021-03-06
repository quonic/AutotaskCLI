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
        # Create the Query and Invoke the other objects or code,
        # such as Fields and other Conditions
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
        # Verify that the Query is valid to conver to XML
        $scriptB = [ScriptBlock]::Create($sbString)
        [System.Xml.Linq.XElement]$Xml = NewXmlDocument.ps1 -ScriptBlock $scriptB
        try {
            # TODO: either remove this or create error handling code
        }
        catch {
            throw "Field is not formated correctly, see Get-Help NewXmlDocument.ps1."
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
        # Create the condition and Invoke the other objects or code,
        # such as Fields and other Conditions
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
        [Object]
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
        #$ProcessInputObject = $false
        if ($InputObject) {
            # Process the InputObject
            [string]$Field = $InputObject.Property
            [string]$Value = $InputObject.Value
            [string]$binaryOperator = $InputObject.Operator
            #$ProcessInputObject = $true
        }
        elseif ($Property -and $Value) {
            # Prop and Value where provided so don't set Value to an empty string
            [string]$Field = $Property
            if ($Value.value__) {
                $Value = $Value.value__
            }
        }
        else {
            # Value wasn't provided so it must be an empty string per API
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
        $Query,
        [switch]
        $IgnoreThresholdCheck
    )
    begin {
        $response = $AutoTask.query($Query)
        # Check if we got exactly 500 results, and get more if so.
        if ($response.EntityResults.Count -eq 500) {
            Write-Debug -Message "More than 500 results"
            # API spec says use last id as the starting point from last query
            # Below does that
            # Remove any past queries that are from us getting more results
            # Note: You should be querying on id anyways unless you are getting more results. "id" is not in the database. It's ephemeral to the results.
            [System.Xml.Linq.XElement]$Xml = $Query
            $IdElement = $Xml.Elements("query").Elements("field") | Where-Object {$_.FirstNode.Value -like "id"}
            $LastID = $idElement.FirstNode.NextNode.Value

            if ($IdElement -and $LastID -or ($idElement.FirstNode.NextNode.FirstAttribute.Value -contains "GreaterThan")) {
                # Remove the id field from the query so we can add the next one
                Write-Debug -Message "Removing $($_.FirstNode.NextNode.FirstAttribute.Value)"
                $IdElement.Remove()
            }
            # Get the id needed to put in the new query
            $ID = $response.EntityResults[$response.EntityResults.Count - 1].id
            Write-Debug -Message "Adding $ID"
            # Create new id field
            $IdField = Get-Field "id" -GreaterThan "$ID"
            $IdFieldScript = [ScriptBlock]::Create($IdField)
            [System.Xml.Linq.XElement]$XmlID = NewXmlDocument.ps1 -ScriptBlock $IdFieldScript
            $Xml.LastNode.AddFirst($XmlID)
            $NewQuery = $Xml.ToString()
            Write-Debug -Message "Query:`r`n$NewQuery"

            $TAUI = Get-APIUsage -Autotask $AutoTask

            if ($IgnoreThresholdCheck) {
                Write-Verbose -Message "Threshold%: $($TAUI.Percentage)"
                Start-Sleep -Seconds 1
            }
            else {
                # Sleep as we don't want to make 1000 calls in 60 seconds and get banned
                $SleepTime = [Math]::Round($([math]::log10($TAUI.Percentage) * 10 + 1), 0)
                Write-Verbose -Message "Threshold%: $($TAUI.Percentage), Sleeping for $SleepTime seconds"
                # We will sleep from 1 to 21 seconds depending on the Threshold %
                if ($SleepTime -le 0) {
                    Start-Sleep -Seconds 1
                }
                else {
                    Start-Sleep -Seconds $SleepTime
                }
            }
            # Query again for next set of results. Recursion ;)
            if ($NewQuery) {
                $newresponse = Invoke-ATQuery -AutoTask $AutoTask -Query $NewQuery -IgnoreThresholdCheck:$IgnoreThresholdCheck
            }
            else {
                # This shouldn't be thrown if $IdElement found an id in the old Query
                throw "NewQuery wasn't created"
            }

            $Namespace = $response.GetType().Namespace
            if ($newresponse.ReturnCode -eq 1) {
                # No problems so add the past results to the new results as a new object
                $ATWSResponse = New-Object ($Namespace + ".ATWSResponse")
                $ATWSResponse.ReturnCode = 1
                $ATWSResponse.EntityResults = $response.EntityResults + $newresponse.EntityResults
                $ATWSResponse.EntityResultType = $response.EntityResultType
                $ATWSResponse.Errors = $response.Errors + $newresponse.Errors
                $ATWSResponse.EntityReturnInfoResults = $response.EntityReturnInfoResults + $newresponse.EntityReturnInfoResults
                $response = $ATWSResponse
                # Off to returning the results
            }
            elseif ($newresponse.GetType().BaseType.Name -like "Array" -and $newresponse.Count -gt 1) {
                # Checking if the results are an array and are more than 1, else there might be an error.
                # This would be from where we returned just EntityResults, so merge the two arrays of results.
                $response = $response.EntityResults + $newresponse
            }
        }
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
        else {
            return $response.EntityResults
        }
    }
}
New-Alias -Name "ATQuery" -Value "Get-Query" -Force -Scope Global -Option ReadOnly