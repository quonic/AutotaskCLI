using System.Management.Automation;
using System.Net.Mail;
using AutotaskCLI.Autotask;

namespace AutotaskCLI
{
    [Cmdlet(VerbsCommunications.Connect, "Autotask")]
    public class ConnectAutotask : PSCmdlet
    {
        public PSCredential Credential {
            get { return creds; }
            set { creds = value; }
        }
        private PSCredential creds;
        protected override void ProcessRecord()
        {
            MailAddress emailAddress = new MailAddress(creds.UserName);
            ATWSZoneInfo ZoneInfo = new ATWSZoneInfo(emailAddress.Address);
            string url = ZoneInfo.URL.Replace(".wsdl", ".wsdl");
            ATWSSoapClient a = new ATWSSoapClient(url);

            AutotaskIntegrations AI = new AutotaskIntegrations
            {
                PartnerID = emailAddress.Address,
                IntegrationCode = creds.GetNetworkCredential().Password
            };

            //TODO: some how save AI or the PSCreds object in memory for other cmdlets to access


            QueryXML sXML = new QueryXML();
            sXML.Entity = "contact";
            sXML.Children = new Query();
            sXML.Children.Items.Add(new Field("firstname", Ops.Equal, "John"));
            sXML.Children.Items.Add(new Field("lastname", Ops.Equal, "Doe"));

            a.query(AI, sXML.ToXML());
        }
    }
    
}
