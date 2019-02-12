using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutotaskCLI.Autotask;
using AutotaskCLI.Classes;
using System.IO;
using System.Management.Automation;
using System.Xml;
using System.Xml.Serialization;

namespace AutotaskCLI.Classes
{
    class PostQuery
    {
        private AutotaskIntegrations AI = new AutotaskIntegrations();
        private string url;
        private string partnerID;
        private string iCode;
        private ATWSSoapClient soapClient;

        public string PartnerID { get => partnerID; set => partnerID = value; }
        public string ICode { get => iCode; set => iCode = value; }
        public string Url { get => url; set => url = value; }
        public ATWSSoapClient SoapClient { get => soapClient; set => soapClient = value; }

        public PostQuery() {}

        public PostQuery(SessionState sessionState)
        {
            this.SetSessionState(sessionState);
        }

        public void SetSessionState(SessionState sessionState)
        {
            // Check that Connect-Autotask was called
            if (sessionState.PSVariable.GetValue("AutotaskAPISoapEmail") != null &&
                sessionState.PSVariable.GetValue("AutotaskAPISoapICode") != null &&
                sessionState.PSVariable.GetValue("AutotaskAPISoapURL") != null)
            {
                PartnerID = sessionState.PSVariable.GetValue("AutotaskAPISoapEmail").ToString();
                ICode = sessionState.PSVariable.GetValue("AutotaskAPISoapICode").ToString();
                Url = sessionState.PSVariable.GetValue("AutotaskAPISoapURL").ToString();
                AI.PartnerID = PartnerID;
                AI.IntegrationCode = ICode;
                SoapClient = new ATWSSoapClient(Url);
            }
            else
            {
                throw new Exception("Please run Connect-Autotask");
            }
        }

        public ATWSResponse Query(string XML)
        {
            // Send query to Autotask and check for errors from Autotask
            ATWSResponse response = SoapClient.query(AI, XML);
            if (response.Errors != null && response.Errors.Length > 0)
            {
                throw new Exception(response.Errors[0].Message);
            }
            else
            {
                //TODO: Add a bit of code to get more data if there are more than 500 items returned
                return response;
            }
        }
    }
}
