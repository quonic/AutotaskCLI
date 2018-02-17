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
        $Query = Query "Resource" {
            #Field "Active" -Equals $true
            if ($FirstName) {Field "FirstName" -Like "$FirstName"}
            if ($LastName) {Field "LastName" -Like "$LastName"}
            if ($UserName) {Field "UserName" -Equals "$UserName"}
            if ($Title) {Field "Title" -Like "$Title"}
        }
    }
    
    process {
    }
    
    end {
        return Invoke-ATQuery -AutoTask $AutoTask -Query $Query
    }
}