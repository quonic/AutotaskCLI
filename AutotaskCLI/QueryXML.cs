using System;
using System.Xml;
using System.Xml.Serialization;
using System.Collections.Generic;
using System.Xml.Schema;
using System.Collections;

namespace AutotaskCLI
{
    [Serializable]
    [XmlRoot(Namespace = "")]
    public class QueryXML
    {
        [XmlElement(
            DataType = "string",
            ElementName = "Entity")]
        public string Entity { get; set; }
        [XmlElement(
            ElementName = "Query"
            )]
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

    [Serializable]
    [XmlType]
    public class Expression
    {
        private string op;
        
        [XmlAttribute(
            AttributeName = "op")]
        public string Operator { get => op; set => op = value; }

        [XmlText]
        public string Text;

        public Expression() { }

        public Expression(string Text, ExpressionType Operator) {
            this.Text = Text;
            this.Operator = Operator.Value;
        }

        
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

    [Serializable]
    public class Query
    {
        private List<Condition> condition;
        private List<Field> field;

        [XmlArrayItem(Type = typeof(Field),
            ElementName = "Field",
            IsNullable = true)]
        public List<Field> Field { get => field; set => field = value; }

        [XmlArrayItem(Type = typeof(Condition),
            ElementName = "Condition",
            IsNullable = true)]
        public List<Condition> Condition { get => condition; set => condition = value; }

        public Query() {}
        public Query(Condition condition)
        {
            this.condition = new List<Condition>
            {
                condition
            };
        }
        public Query(Field field)
        {
            this.field = new List<Field>
            {
                field
            };
        }
        public Query(IEnumerable<Field> field)
        {
            this.field = new List<Field>(field);
        }
        public Query(IEnumerable<Condition> condition)
        {
            this.condition = new List<Condition>(condition);
        }
    }

    [Serializable]
    public class Field
    {
        private string text;
        private Expression op;

        [XmlText]
        public string Text { get => text; set => text = value; }

        [XmlElement(
            ElementName = "expression")]
        public Expression Operator { get => op; set => op = value; }

        public Field() { }
        public Field(string Text, Expression Operator)
        {
            this.Text = Text;
            this.Operator = Operator;
        }
    }

    [Serializable]
    public class Condition
    {
        private string isOr;
        [XmlAttribute(
            AttributeName = "Operator"
            )]
        public string Operator { get => isOr; set => isOr = value; }

        private List<Condition> condition;
        private List<Field> field;

        [XmlArrayItem(Type = typeof(Field),
            ElementName = "Field",
            IsNullable = true)]
        public List<Field> Fields { get => field; set => field = value; }

        [XmlArrayItem(Type = typeof(Condition),
            ElementName = "Condition",
            IsNullable = true)]
        public List<Condition> Conditions { get => condition; set => condition = value; }

        public Condition() { }

        public Condition(OperatorType Operator)
        {
            this.Operator = Operator.ToString();
        }

        public Condition(OperatorType Operator, IEnumerable<Field> field)
        {
            this.Operator = Operator.ToString();
            this.field = new List<Field>(field);
        }

        public Condition(OperatorType Operator, IEnumerable<Condition> condition)
        {
            this.Operator = Operator.ToString();
            this.condition = new List<Condition>(condition);
        }
    }
}
