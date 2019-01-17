using AutotaskCLI.Autotask;
using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace AutotaskCLI
{
    [Cmdlet(VerbsCommon.Get, "Ticket")]
    public class GetTicket : PSCmdlet
    {
        private QueryXML sXML = new QueryXML
        {
            Entity = "Ticket",
            Children = new Query()
        };
        private AutotaskIntegrations AI = new AutotaskIntegrations();
        private ATWSSoapClient SoapClient = new ATWSSoapClient();
        private Query Filter = new Query();

        [Parameter(
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "TicketNumber"
            )]
        public string[] TicketNumber { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "Name"
            )]
        public string FirstName { get; set; }
        [Parameter(
            Mandatory = false,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "Name"
            )]
        public string LastName { get; set; }
        [Parameter(
            Mandatory = false,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "Name"
            )]
        public string Status { get; set; }

        protected override void BeginProcessing()
        {
            base.BeginProcessing();

            // Get our session data
            AI.PartnerID = SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapEmail").Value.ToString();
            AI.IntegrationCode = SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapICode").Value.ToString();
            ATWSSoapClient SoapClient = new ATWSSoapClient(SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapURL").Value.ToString());
            
        }
        protected override void ProcessRecord()
        {
            if(ParameterSetName == "Name") {
                // This is (FirstName && LastName && Status) logic to AutoTask
                sXML.Children.Items.Add(new Field("FirstName", Ops.Like, FirstName));
                sXML.Children.Items.Add(new Field("LastName", Ops.Like, LastName));
                sXML.Children.Items.Add(new Field("Status", Ops.Like, Status));
            }
            else if (ParameterSetName == "TicketNumber") {
                WriteDebug(text: "Tickets to search for: " + TicketNumber.Length);
                WriteDebug(text: "TicketNumber is of object type: " + TicketNumber.GetType());

                if (TicketNumber.Length > 1 || TicketNumber is Array)
                {
                    Condition condition = new Condition(true);
                    foreach (var item in TicketNumber)
                    {
                        condition.AddItem(new Field("TicketNumber", Ops.Equal, item));
                    }
                    Filter.Items.Add(condition);
                    sXML.Children.Items.Add(Filter);
                }
                else
                {
                    sXML.Children.Items.Add(new Field("TicketNumber", Ops.Equal, TicketNumber[0]));
                }
            }
            
            
        }
        protected override void EndProcessing()
        {
            base.EndProcessing();

            WriteObject(SoapClient.query(AI, sXML.ToXML()));
        }
    }
}
