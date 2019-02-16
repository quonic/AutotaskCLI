using System;
using System.Management.Automation;
using AutotaskCLI.Autotask;

namespace AutotaskCLI.Cmdlets
{
    [Cmdlet(VerbsCommon.New, "Ticket")]
    public class NewTicket : PSCmdlet
    {
        private AutotaskIntegrations AI = new AutotaskIntegrations();
        private string partnerID, ICode, Url;

        [Parameter(
            Mandatory = false)]
        public string Title;

        [Parameter(
            Mandatory = false)]
        public SwitchParameter OutXML;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            // Get our session data
            // Check that Connect-Autotask was called
            if (SessionState.Module.SessionState.PSVariable.GetValue("AutotaskAPISoapEmail") != null &&
                SessionState.Module.SessionState.PSVariable.GetValue("AutotaskAPISoapICode") != null &&
                SessionState.Module.SessionState.PSVariable.GetValue("AutotaskAPISoapURL") != null)
            {
                partnerID = SessionState.Module.SessionState.PSVariable.GetValue("AutotaskAPISoapEmail").ToString();
                ICode = SessionState.Module.SessionState.PSVariable.GetValue("AutotaskAPISoapICode").ToString();
                Url = SessionState.Module.SessionState.PSVariable.GetValue("AutotaskAPISoapURL").ToString();
                AI.PartnerID = partnerID;
                AI.IntegrationCode = ICode;
                ATWSSoapClient SoapClient = new ATWSSoapClient(Url);
            }
            else
            {
                WriteError(
                    errorRecord: new ErrorRecord(
                        exception: new Exception("Please run Connect-Autotask"),
                        errorId: "1000",
                        errorCategory: ErrorCategory.ObjectNotFound,
                        targetObject: partnerID));
            }
        }

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
                entity[0].Fields = new Autotask.Field[10];
                new Autotask.createRequest(AI, entity);
                
            }
            base.EndProcessing();
        }
    }
}
