
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
        # Check if we can Query Tickets
        if (-not ($AutoTask.getEntityInfo() | Where-Object {$_.Name -like "Ticket"}).CanQuery) {
            throw "You do not have Query permissions for Tickets."
        }
    }
    
    process {
        if ($Query) {
            # We have a Query so do as asked
            Invoke-ATQuery -AutoTask $AutoTask -Query $Query
        }
        elseif ($TicketID) {
            # Get the Notes for the specified Ticket
            # TODO: Add logic to check if ticket exists or let Query handle this?
            Invoke-ATQuery -AutoTask $AutoTask -Query $(
                Query "TicketNote" {
                    Field -Property "TicketID" -Equals -Value $TicketID
                })
        }
    }
    
    end {
    }
}
