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
            Query = new Query()
        };
        //private AutotaskIntegrations AI = new AutotaskIntegrations();
        //private ATWSSoapClient SoapClient = new ATWSSoapClient();

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
            //AI.PartnerID = SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapEmail").Value.ToString();
            //AI.IntegrationCode = SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapICode").Value.ToString();
            //ATWSSoapClient SoapClient = new ATWSSoapClient(SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapURL").Value.ToString());
            
        }
        protected override void ProcessRecord()
        {
            if(ParameterSetName == "Name") {
                // This is (FirstName && LastName && Status) logic to AutoTask
                sXML.Query.Field.Add(new Field("FirstName", new Expression(FirstName, ExpressionType.Like)));
                sXML.Query.Field.Add(new Field("LastName", new Expression(LastName, ExpressionType.Like)));
                sXML.Query.Field.Add(new Field("Status", new Expression(Status, ExpressionType.Like)));
            }
            else if (ParameterSetName == "TicketNumber") {
                WriteDebug(text: "Tickets to search for: " + TicketNumber.Length);
                WriteDebug(text: "TicketNumber is of object type: " + TicketNumber.GetType());

                if (TicketNumber.Length >= 1 && TicketNumber is Array)
                {
                    Condition cList = new Condition(Operator.Or);
                    foreach (var item in TicketNumber)
                    {
                        // Getting "System.NullReferenceException: 'Object reference not set to an instance of an object.'" here
                        cList.Fields.Add(new Field("TicketNumber", new Expression(item, ExpressionType.Equal)));
                    }
                    sXML.Query.Condition.Add(cList);
                }
                else
                {
                    sXML.Query.Field.Add(new Field("TicketNumber", new Expression(TicketNumber[0], ExpressionType.Like)));
                }
            }
            
            
        }
        protected override void EndProcessing()
        {
            base.EndProcessing();

            //WriteObject(SoapClient.query(AI, sXML.ToXML()));
            WriteObject(sXML.ToXML());
        }
    }
}
