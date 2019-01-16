using System;
using System.IO;
using System.Management.Automation;
using System.Net.Mail;
using System.Collections.Generic;
using System.Xml;
using System.Xml.Serialization;
using AutotaskCLI.Autotask;
using System.Xml.Linq;

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
            a.query(AI, "");
        }
    }
    //TODO: Something here
    //private class 
    public class Ops
    {
        private Ops(string value) { Value = value; }

        public string Value { get; set; }

        public static Ops Equal { get { return new Ops("Equals"); } }
        public static Ops NotEqual { get { return new Ops("Not Equals"); } }
        public static Ops LessThan { get { return new Ops("Less Than"); } }
        public static Ops LessThanOrEqual { get { return new Ops("Less Than Or Equal"); } }
        public static Ops GreaterThan { get { return new Ops("Greater Than"); } }
        public static Ops GreaterThanOrEqual { get { return new Ops("Greater Than Or Equal"); } }
        public static Ops BeginsWith { get { return new Ops("Begins With"); } }
        public static Ops EndsWith { get { return new Ops("Ends With"); } }
        public static Ops Contains { get { return new Ops("Contains"); } }
        public static Ops IsNull { get { return new Ops("Is Null"); } }
        public static Ops IsNotNull { get { return new Ops("Is Not Null"); } }
        public static Ops IsThisDay { get { return new Ops("Is This Day"); } }
        public static Ops Like { get { return new Ops("Like"); } }
        public static Ops NotLike { get { return new Ops("Not Like"); } }
        public static Ops SoundsLike { get { return new Ops("Sounds Like"); } }

    }

    class XmlConverter
    {
        public object data;
    }

    [Serializable]
    public class QueryXML
    {
        public struct Condition
        {
            public string field;
            public Ops op;
            public string expression;

            public Condition(string field, Ops op, string expression)
            {
                this.field = field;
                this.op = op;
                this.expression = expression;
            }
        }
        [XmlAttribute]
        public string Entity { get; set; }
        public string Op { get; set; }
        public string Field { get; set; }
        public string Expression { get; set; }
        public List<Condition> Conditions { get; set; }
        public void AddCondition(string field, Ops op, string expression) { this.Conditions.Add(new Condition(field, op, expression)); }

        public QueryXML() => Op = Ops.Equal.Value;
        /*
          class QueryXML
            Condition = Struct.new(:field, :op, :expression)
            attr_accessor :entity, :op, :field, :expression, :conditions

            def initialize
              yield self
              self.op ||= 'equals'
            end

            def add_condition(field, op, expression)
              self.conditions ||= []
              self.conditions << Condition.new(field, op, expression)
            end
          #end
            */

        public override string ToString()
        {
            return "";
            
            /*
            
                sXML do
                  cdata(Nokogiri::XML::Builder.new do |xml|
                    xml.queryxml do
                      xml.entity entity
                      xml.query do
                        if field
                          xml.field field do
                            xml.expression expression, op: op
                          end
                        else
                          conditions.each do |condition|
                            xml.condition do
                              xml.field condition.field do
                                xml.expression condition.expression,
                                  op: condition.op
                              end
                            end
                          end
                        end
                      end
                    end
                  end.doc.root)
                end
        */
        }
    }
}
