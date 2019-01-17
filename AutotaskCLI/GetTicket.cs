using AutotaskCLI.Autotask;
using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace AutotaskCLI
{
    [Cmdlet(VerbsCommon.Get, "Ticket")]
    public class GetTicket : PSCmdlet
    {
        private QueryXML sXML = new QueryXML()
        {
            Entity = "Ticket"
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
                List<Field> Filter = new List<Field>(3);
                Filter.Insert(0, new Field("FirstName", new Expression(FirstName, ExpressionType.Like)));
                Filter.Insert(1, new Field("LastName", new Expression(LastName, ExpressionType.Like)));
                Filter.Insert(2, new Field("Status", new Expression(Status, ExpressionType.Like)));
                sXML.Query = new Query(Filter);
                    
            }
            else if (ParameterSetName == "TicketNumber") {

                sXML.Query = new Query();

                WriteDebug(text: "Tickets to search for: " + TicketNumber.Length);
                WriteDebug(text: "TicketNumber is of object type: " + TicketNumber.GetType());

                if (TicketNumber.Length > 1 && TicketNumber is Array)
                {
                    Condition cList = new Condition(Operator.Or);
                    List<Field> FilterField = new List<Field>(TicketNumber.Length);
                    for (int i = 0; i < TicketNumber.Length - 1; i++) {
                        FilterField.Insert(i,new Field("TicketNumber", new Expression(TicketNumber[i], ExpressionType.Equal)));
                    }

                    cList.Fields.AddRange(FilterField);
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
            /*
             sample output:
             <?xml version="1.0" encoding="utf-16"?>
             <QueryXML xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                Ticket
                <Query>
                    <Field Expression="AutotaskCLI.Expression">
                        FirstName
                    </Field>
                    <Field Expression="AutotaskCLI.Expression">
                        LastName
                    </Field>
                    <Field Expression="AutotaskCLI.Expression">
                        Status
                    </Field>
                </Query>
            </QueryXML>
             */
            WriteObject(sXML.ToXML());
        }
    }
}
