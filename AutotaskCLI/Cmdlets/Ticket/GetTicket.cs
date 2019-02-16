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
        private string partnerID, ICode, Url;

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

        }
        protected override void ProcessRecord()
        {

            if (ParameterSetName == "Name") {
                // This is (FirstName && LastName && Status) logic to AutoTask
                // TODO: Expand this into a more selectable method
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
                    // More than one ticket was asked to be searched for, construct (Ticket1 or Ticket2 or ...) query
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
                    // Only one ticket was asked to be searched for, constuct (Ticket1) query
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
                // Output raw XML, usually for debug porposes
                WriteObject(sXML.ToXML());
            }
            else
            {
                // Send query to Autotask and check for errors from Autotask
                ATWSSoapClient SoapClient = new ATWSSoapClient();
                ATWSResponse response = SoapClient.query(AI, sXML.ToXML());
                if(response.Errors != null && response.Errors.Length > 0)
                {
                    Exception exception = new Exception(response.Errors[0].Message);
                    ErrorRecord errorRecord = new ErrorRecord(
                        exception: exception,
                        errorId: response.ReturnCode.ToString(),
                        errorCategory: ErrorCategory.NotSpecified,
                        targetObject: response.ReturnCode);

                    WriteError(errorRecord);
                }
                else
                {
                    WriteObject(response.EntityResults);
                }
            }
        }
    }
}
