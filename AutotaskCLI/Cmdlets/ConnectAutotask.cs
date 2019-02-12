using System.Collections.Generic;
using System.Management.Automation;
using System.Net.Mail;
using System.Reflection;
using AutotaskCLI.Autotask;

namespace AutotaskCLI
{
    [Cmdlet(VerbsCommunications.Connect, "Autotask")]
    public class ConnectAutotask : PSCmdlet
    {
        
        [Parameter(
            Mandatory = true
            )]
        public PSCredential Credential { get; set; }

        // For future backwords compatibility
        //[Parameter(
        //    Mandatory = false
        //    )]
        //[ValidateSet(new string[]{ "1.5", "1.6" }, IgnoreCase = true)]
        //public string Version { get; set; }

        protected override void ProcessRecord()
        {
            // Validate username is an email address, might change this to regex if there is ever
            //a SOAP library that can work under Powershell 6 under linux
            MailAddress emailAddress = new MailAddress(Credential.UserName);
            // Version 1.5 way of getting Zone Info
            //ATWSZoneInfo ZoneInfo = new ATWSZoneInfo(emailAddress.Address);
            ATWSSoapClient ZoneInfo = new ATWSSoapClient();

            WriteVerbose("Looking up zone for user " + Credential.UserName + ".");
            ATWSZoneInfo ZoneInfoData = ZoneInfo.getZoneInfo(Credential.UserName);

            WriteDebug("User: " + Credential.UserName + "; Zone URL = " + ZoneInfoData.URL + ";");
            
            // Below comment might not be needed as 1.6 doesn't report back asmx, but wsdl back.
            //string url = ZoneInfoData.URL.Replace(".asmx", ".wsdl");

            WriteVerbose("Creating Soap Client");
            ATWSSoapClient SoapClient = new ATWSSoapClient(ZoneInfoData.URL);

            WriteVerbose("Creating Credential Object");
            AutotaskIntegrations AI = new AutotaskIntegrations
            {
                PartnerID = emailAddress.Address,
                IntegrationCode = Credential.GetNetworkCredential().Password
            };

            WriteVerbose("Connected to Autotask...");

            WriteVerbose("Getting Entity Information...");

            EntityInfo[] EntitiesInfo = SoapClient.getEntityInfo(AI);

            object[] Entities = new object[EntitiesInfo.Length];
            for (int i = 0; i < EntitiesInfo.Length; i++)
            {
                Autotask.Field[] CurFieldList = SoapClient.GetFieldInfo(AI, EntitiesInfo[i].Name);
                Entities[i] = CurFieldList;
            }
            
            


            // Save email, API code, and URL to the module's private ?memory?
            SessionState.Module.SessionState.PSVariable.Set("AutotaskAPISoapEmail", AI.PartnerID);
            SessionState.Module.SessionState.PSVariable.Set("AutotaskAPISoapICode", AI.IntegrationCode);
            SessionState.Module.SessionState.PSVariable.Set("AutotaskAPISoapURL", ZoneInfoData.URL);

            SessionState.Module.SessionState.PSVariable.Set("AutotaskAPIEntitiesInfo", Entities);

        }
    }
    
}
