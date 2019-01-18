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
                Filter.Insert(0, new Field("FirstName", new Expression(FirstName, Expression.ExpressionType.Like)));
                Filter.Insert(1, new Field("LastName", new Expression(LastName, Expression.ExpressionType.Like)));
                Filter.Insert(2, new Field("Status", new Expression(Status, Expression.ExpressionType.Like)));
                sXML.Query = new Query(Filter);
                    
            }
            else if (ParameterSetName == "TicketNumber") {

                

                WriteDebug(text: "Tickets to search for: " + TicketNumber.Length);
                WriteDebug(text: "TicketNumber is of object type: " + TicketNumber.GetType());

                if (TicketNumber.Length > 1 && TicketNumber is Array)
                {
                    
                    List<Field> FilterField = new List<Field>(TicketNumber.Length);
                    for (int i = 0; i < TicketNumber.Length - 1; i++) {
                        FilterField.Insert(i,new Field("TicketNumber", new Expression(TicketNumber[i], Expression.ExpressionType.Equal)));
                    }

                    Condition cList = new Condition(OperatorType.Or, FilterField);
                    sXML.Query = new Query(cList);
                }
                else
                {
                    sXML.Query.Field.Add(new Field("TicketNumber", new Expression(TicketNumber[0], Expression.ExpressionType.Like)));
                }
            }
            
            
        }
        protected override void EndProcessing()
        {
            base.EndProcessing();

            //WriteObject(SoapClient.query(AI, sXML.ToXML()));
            /*
             sample output:
            Get-Ticket -TicketNumber "asdf","asdff"
            <QueryXML>
              <Entity>Ticket</Entity>
              <Query>
                <Condition> // TODO: Need to remove this
                  <Condition Operator="Or">
                    <Fields> // TODO: Need to remove this
                      <Field>TicketNumber<expression op="Equals">asdf</expression></Field>
                    </Fields>
                  </Condition>
                </Condition>
              </Query>
            </QueryXML>

            Get-Ticket -FirstName "asdf" -LastName "asdff" -Status "Closed"
            <QueryXML>
              <Entity>Ticket</Entity>
              <Query>
                <Field>
                  <Field>FirstName<expression op="Like">asdf</expression></Field>
                  <Field>LastName<expression op="Like">asdff</expression></Field>
                  <Field>Status<expression op="Like">Closed</expression></Field>
                </Field>
              </Query>
            </QueryXML>
             */
            WriteObject(sXML.ToXML());
        }
    }
}
