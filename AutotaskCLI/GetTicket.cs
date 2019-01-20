using AutotaskCLI.Autotask;
using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using System.Xml;
using System.Xml.Serialization;

namespace AutotaskCLI
{
    [Cmdlet(VerbsCommon.Get, "Ticket")]
    public class GetTicket : PSCmdlet
    {
        private QueryXML sXML = new QueryXML()
        {
            Entity = "Ticket"
        };
        private AutotaskIntegrations AI = new AutotaskIntegrations();
        

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
        [Parameter(
            Mandatory = false
            )]
        public SwitchParameter OutXml { get; set; }

        protected override void BeginProcessing()
        {
            base.BeginProcessing();

            // Get our session data
            if (!OutXml == true)
            {
                AI.PartnerID = SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapEmail").Value.ToString();
                AI.IntegrationCode = SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapICode").Value.ToString();
                ATWSSoapClient SoapClient = new ATWSSoapClient(SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapURL").Value.ToString());
            }

        }
        protected override void ProcessRecord()
        {

            if (ParameterSetName == "Name") {
                // This is (FirstName && LastName && Status) logic to AutoTask
                sXML.Query = new Query(new List<Field> {
                    new Field
                    {
                        Text = "FirstName",
                        Expression = new Expression
                        {
                            Text = FirstName,
                            Op = Expression.ExpressionType.Like.Value
                        }
                    },
                    new Field
                    {
                        Text = "LastName",
                        Expression = new Expression
                        {
                            Text = LastName,
                            Op = Expression.ExpressionType.Like.Value
                        }
                    },
                    new Field
                    {
                        Text = "Status",
                        Expression = new Expression
                        {
                            Text = Status,
                            Op = Expression.ExpressionType.Like.Value
                        }
                    }
                });
            }
            else if (ParameterSetName == "TicketNumber") {

                

                WriteDebug(text: "Tickets to search for: " + TicketNumber.Length);
                WriteDebug(text: "TicketNumber is of object type: " + TicketNumber.GetType());

                if (TicketNumber.Length > 1 && TicketNumber is Array)
                {
                    //sXML.Query.Condition = new List<Condition>();
                    sXML.Query = new Query();
                    foreach (var ticketNumber in TicketNumber)
                    {
                        Condition ticketOr = new Condition { Operator = Condition.OperatorType.Or.Value };
                        ticketOr.Field = new List<Field> {
                            new Field
                            {
                                Text = "TicketNumber",
                                Expression = new Expression
                                {
                                    Text = ticketNumber,
                                    Op = Expression.ExpressionType.Like.Value
                                }
                            }
                        };
                        sXML.Query.Condition.Add(ticketOr);
                    }
                }
                else
                {
                    sXML.Query.Field.Add(new Field
                    {
                        Text = "TicketNumber",
                        Expression = new Expression
                        {
                            Text = TicketNumber[0],
                            Op = Expression.ExpressionType.Like.Value
                        }
                    });
                }
            }
            
            
        }
        protected override void EndProcessing()
        {
            base.EndProcessing();

            if (OutXml == true)
            {
                WriteObject(sXML.ToXML());
            }
            else
            {
                ATWSSoapClient SoapClient = new ATWSSoapClient();
                WriteObject(SoapClient.query(AI, sXML.ToXML()));
            }
            /*
             sample output:
            Get-Ticket -TicketNumber "asdf","asdff" -OutXml
            <QueryXML>
              <Entity>Ticket</Entity>
              <Query>
                <Condition Operator="Or">
                  <Field>
                    <expression op="Like">asdf</expression>TicketNumber</Field>
                </Condition>
                <Condition Operator="Or">
                  <Field>
                    <expression op="Like">asdff</expression>TicketNumber</Field>
                </Condition>
              </Query>
            </QueryXML>

            Get-Ticket -FirstName "asdf" -LastName "asdff" -Status "Closed" -OutXml
            <QueryXML>
              <Entity>Ticket</Entity>
              <Query>
                <Field>
                  <expression op="Like">asdf</expression>FirstName</Field>
                <Field>
                  <expression op="Like">asdff</expression>LastName</Field>
                <Field>
                  <expression op="Like">Closed</expression>Status</Field>
              </Query>
            </QueryXML>
             */

        }
    }
}
