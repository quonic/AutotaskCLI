using AutotaskCLI.Autotask;
using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using System.Xml;
using System.Xml.Serialization;

namespace AutotaskCLI.Cmdlets
{
    [Cmdlet(VerbsCommon.Get, "Resource")]
    public class GetResource : PSCmdlet
    {
        private QueryXML sXML = new QueryXML()
        {
            Entity = "Resource"
        };
        private AutotaskIntegrations AI = new AutotaskIntegrations();
        private string partnerID, ICode, Url;

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
            ValueFromPipelineByPropertyName = true
            )]
        public SwitchParameter NotActive { get; set; }
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
                    throw new Exception("Please run Connect-Autotask");
                }
            }

        }
        protected override void ProcessRecord()
        {
            if (ParameterSetName == "Name")
            {
                // This is (FirstName && LastName) logic to AutoTask
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
                            Text = (!NotActive).ToString(),
                            Op = Expression.ExpressionType.Equal.Value
                        }
                    }
                });
            }
            else
            {
                sXML.Query = new Query(new List<Field> {
                    new Field
                    {
                        Text = "Status",
                        Expression = new Expression
                        {
                            Text = (!NotActive).ToString().ToLower(),
                            Op = Expression.ExpressionType.Equal.Value
                        }
                    }
                });
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
                if (response.Errors != null && response.Errors.Length > 0)
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
