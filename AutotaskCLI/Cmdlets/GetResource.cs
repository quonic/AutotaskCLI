using AutotaskCLI.Autotask;
using AutotaskCLI.Classes;
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
        private PostQuery pQuery = new PostQuery();

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
                try
                {
                    pQuery.SetSessionState(SessionState.Module.SessionState);
                }
                catch (Exception ex)
                {
                    WriteError(
                        errorRecord: new ErrorRecord(
                            exception: ex,
                            errorId: "1000",
                            errorCategory: ErrorCategory.ObjectNotFound,
                            targetObject: pQuery.PartnerID));
                    throw ex;
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
                try
                {
                    ATWSResponse response = pQuery.Query(sXML.ToXML());
                    WriteObject(response.EntityResults);
                }
                catch (Exception ex)
                {
                    WriteError(
                        errorRecord: new ErrorRecord(
                            exception: ex,
                            errorId: "1000",
                            errorCategory: ErrorCategory.ObjectNotFound,
                            targetObject: sXML.Query));
                    throw ex;
                }
            }
        }
    }
}
