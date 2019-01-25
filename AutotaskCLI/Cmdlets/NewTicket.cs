using System;
using System.Management.Automation;

namespace AutotaskCLI.Cmdlets
{
    [Cmdlet(VerbsCommon.New, "Ticket")]
    public class NewTicket : PSCmdlet
    {
        [Parameter(
            Mandatory = false)]
        public string Title;

        [Parameter(
            Mandatory = false)]
        public SwitchParameter OutXML;

        protected override void ProcessRecord()
        {
            Autotask.Ticket newTicket = new Autotask.Ticket();
            if(Title != null)
            {
                newTicket.Title = Title;
            }
        }
        protected override void EndProcessing()
        {
            if(OutXML = true)
            {
                // TODO: convert NewTicket to XML
            }
            else
            {
                Autotask.Entity[] entity = new Autotask.Entity[1];
                new Autotask.createRequest(AI, entity);
            }
            base.EndProcessing();
        }
    }
}
