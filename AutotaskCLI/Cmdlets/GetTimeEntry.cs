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
    [Cmdlet(VerbsCommon.Get, "TimeEntry")]
    public class GetTimeEntry : PSCmdlet
    {
        private QueryXML sXML = new QueryXML()
        {
            Entity = "TimeEntry"
        };
        private PostQuery pQuery = new PostQuery();

        // START Identity methods
        // Resource object, First and Last name, or E-Mail
        [Parameter(Mandatory = true, ParameterSetName = "ResourceID")]
        private int ResourceID; // from Resource.id

        [Parameter(Mandatory = true, ParameterSetName = "Name")]
        private string FirstName;

        [Parameter(Mandatory = true, ParameterSetName = "Name")]
        private string LastName;

        [Parameter(Mandatory = true, ParameterSetName = "Email")]
        private string Email;
        // END Identity methods

        [Parameter(
            Mandatory = false
            )]
        [ValidateSet(new string[] { "Ticket", "Task", "Both" }, IgnoreCase = true)]
        public string Type { get; set; }

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

            //sXML.Query = new Query(new List<Field> {
            //        new Field
            //        {
            //            Text = "Status",
            //            Expression = new Expression
            //            {
            //                Text = (!NotActive).ToString().ToLower(),
            //                Op = Expression.ExpressionType.Equal.Value
            //            }
            //        }
            //    });
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
