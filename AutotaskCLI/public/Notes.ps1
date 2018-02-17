
function Get-Note {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object]
        $AutoTask,
        [Parameter(ParameterSetName = "TicketIDSet")]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int]
        $TicketID,
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
        elseif ($TicketID) {
            [Autotask.TicketNote]::new()
            Invoke-ATQuery -AutoTask $AutoTask -Query $(
                Query "TicketNote" {
                    Field -Property "TicketID" -Equals -Value $TicketID
                })
        }
    }
    
    end {
    }
}
