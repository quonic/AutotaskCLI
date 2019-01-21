using System;
using System.Xml;
using System.Xml.Serialization;
using System.Collections.Generic;
using System.Xml.Schema;
using System.Collections;

/*
 * Example use case
 * 
 * First create a QueryXML object
    private QueryXML sXML = new QueryXML()
    {
        Entity = "Ticket"
    };

 * 
 * Then create the Query object with our fields and conditions
 * Below is for fields only
 * 
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
 *
 * Below is for fields in conditions
 * 
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
 *
 * Then to convert the object to a Query XML string
 * 
    sXML.ToXML()
*/



namespace AutotaskCLI
{
    [XmlRoot(ElementName = "expression")]
    public class Expression
    {
        [XmlAttribute(AttributeName = "op")]
        public string Op { get; set; }
        [XmlText]
        public string Text { get; set; }

        public class ExpressionType
        {
            private ExpressionType() { }
            private ExpressionType(string value) { Value = value; }
            [XmlElement]
            public string Value { get; set; }

            public static ExpressionType Equal { get { return new ExpressionType("Equals"); } }
            public static ExpressionType NotEqual { get { return new ExpressionType("Not Equals"); } }
            public static ExpressionType LessThan { get { return new ExpressionType("Less Than"); } }
            public static ExpressionType LessThanOrEqual { get { return new ExpressionType("Less Than Or Equal"); } }
            public static ExpressionType GreaterThan { get { return new ExpressionType("Greater Than"); } }
            public static ExpressionType GreaterThanOrEqual { get { return new ExpressionType("Greater Than Or Equal"); } }
            public static ExpressionType BeginsWith { get { return new ExpressionType("Begins With"); } }
            public static ExpressionType EndsWith { get { return new ExpressionType("Ends With"); } }
            public static ExpressionType Contains { get { return new ExpressionType("Contains"); } }
            public static ExpressionType IsNull { get { return new ExpressionType("Is Null"); } }
            public static ExpressionType IsNotNull { get { return new ExpressionType("Is Not Null"); } }
            public static ExpressionType IsThisDay { get { return new ExpressionType("Is This Day"); } }
            public static ExpressionType Like { get { return new ExpressionType("Like"); } }
            public static ExpressionType NotLike { get { return new ExpressionType("Not Like"); } }
            public static ExpressionType SoundsLike { get { return new ExpressionType("Sounds Like"); } }

            public override string ToString()
            {
                return Value;
            }

        }
    }

    [XmlRoot(ElementName = "Field")]
    public class Field
    {
        [XmlElement(ElementName = "expression")]
        public Expression Expression { get; set; }
        [XmlText]
        public string Text { get; set; }
    }

    [XmlRoot(ElementName = "Condition")]
    public class Condition
    {
        public Condition()
        {
            this.Field = new List<Field>();
            this.condition = new List<Condition>();
            this.Operator = OperatorType.And.Value;
        }

        [XmlElement(ElementName = "Field")]
        public List<Field> Field { get; set; }
        [XmlAttribute(AttributeName = "Operator")]
        public string Operator { get; set; }
        [XmlElement(ElementName = "Condition")]
        public List<Condition> condition { get; set; }

        [Serializable]
        public class OperatorType
        {
            private OperatorType() { }
            private OperatorType(string value) { Value = value; }

            [XmlText]
            public string Value { get; set; }

            public static OperatorType Or { get { return new OperatorType("Or"); } }
            public static OperatorType And { get { return new OperatorType("And"); } }

            public override string ToString()
            {
                return Value;
            }
        }
    }

    [XmlRoot(ElementName = "Query")]
    public class Query
    {
        [XmlElement(ElementName = "Field")]
        public List<Field> Field { get; set; }
        [XmlElement(ElementName = "Condition")]
        public List<Condition> Condition { get; set; }
        public Query() {
            this.Condition = new List<Condition>();
            this.Field = new List<Field>();
        }

        public Query(List<Field> field, List<Condition> condition)
        {
            Field = field;
            Condition = condition;
        }

        public Query(List<Field> field)
        {
            Field = field;
        }

        public Query(List<Condition> condition)
        {
            Condition = condition;
        }
    }

    [XmlRoot(ElementName = "QueryXML")]
    public class QueryXML
    {
        [XmlElement(ElementName = "Entity")]
        public string Entity { get; set; }
        [XmlElement(ElementName = "Query")]
        public Query Query { get; set; }
        public override string ToString()
        {
            return this.ToXML();
        }
        public string ToXML()
        {
            var serializer = new XmlSerializer(this.GetType());
            var emptyNamespaces = new XmlSerializerNamespaces(new[] { XmlQualifiedName.Empty });
            var settings = new XmlWriterSettings
            {
                Indent = true,
                OmitXmlDeclaration = true
            };
            using (System.IO.StringWriter stream = new System.IO.StringWriter())
            using (XmlWriter writer = XmlWriter.Create(stream, settings))
            {
                serializer.Serialize(writer, this, emptyNamespaces);
                return stream.ToString();
            }
        }
    }
}
