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
        private Condition CurrentCondition = new Condition();
        private Autotask.Field CurrentField = new Autotask.Field();
        [Parameter(
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "TicketNumber"
            )]
        public string[] TicketNumber { get; set; }
        protected override void BeginProcessing()
        {
            base.BeginProcessing();

            AI.PartnerID = SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapEmail").Value.ToString();
            AI.IntegrationCode = SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapICode").Value.ToString();
            ATWSSoapClient SoapClient = new ATWSSoapClient(SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapURL").Value.ToString());
            SoapClient.Endpoint.Address = new System.ServiceModel.EndpointAddress(SessionState.Module.SessionState.PSVariable.Get("AutotaskAPISoapURL").Value.ToString());

            
        }
        protected override void ProcessRecord()
        {
            if(TicketNumber.Length > 1)
            {
                CurrentCondition.IsOr = true;
                foreach (var item in TicketNumber)
                {
                    CurrentCondition.AddItem(new Field("TicketNumber", Ops.Equal, item));
                }
                sXML.Children.Items.Add(CurrentCondition);
            }
            else
            {
                sXML.Children.Items.Add(new Field("TicketNumber", Ops.Equal, TicketNumber[0]));
            }
        }
        protected override void EndProcessing()
        {
            base.EndProcessing();
            
            SoapClient.query(AI, sXML.ToXML());
        }
    }
}
