function Get-ATUser {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "AllRequired")]
        [Parameter(ParameterSetName = "NameSearch")]
        [Parameter(ParameterSetName = "UserNameSearch")]
        [Parameter(ParameterSetName = "TitleSearch")]
        [Parameter(ParameterSetName = "EmailSearch")]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object]
        $AutoTask,
        [Parameter(ParameterSetName = "NameSearch", ValueFromPipelineByPropertyName)]
        [string]$FirstName,
        [Parameter(ParameterSetName = "NameSearch", ValueFromPipelineByPropertyName)]
        [string]$LastName,
        [Parameter(ParameterSetName = "EmailSearch", ValueFromPipelineByPropertyName)]
        $Email,
        [Parameter(ParameterSetName = "UserNameSearch", ValueFromPipelineByPropertyName)]
        $UserName,
        [Parameter(ParameterSetName = "TitleSearch", ValueFromPipelineByPropertyName)]
        $Title
    )
    
    begin {
        $Query = Get-Query "Resource" {
            #Field "Active" -Equals $true
            if ($FirstName) {Get-Field "FirstName" -Like "$FirstName"}
            if ($LastName) {Get-Field "LastName" -Like "$LastName"}
            if ($UserName) {Get-Field "UserName" -Equals "$UserName"}
            if ($Title) {Get-Field "Title" -Like "$Title"}
        }
    }
    
    process {
    }
    
    end {
        return Invoke-ATQuery -AutoTask $AutoTask -Query $Query
    }
}