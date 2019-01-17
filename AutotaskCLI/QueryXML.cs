using System;
using System.Xml;
using System.Xml.Serialization;
using System.Collections.Generic;
using System.Xml.Schema;

namespace AutotaskCLI
{
    [Serializable]
    public class QueryXML
    {
        [XmlText(DataType = "string")]
        public string Entity { get; set; }
        [XmlElement(
            DataType = "Query",
            ElementName = "Query",
            Form = XmlSchemaForm.Unqualified,
            IsNullable = false,
            Namespace = "QueryXML",
            Order = 0,
            Type = typeof(Query)
            )]
        public Query Query { get; set; }

        public override string ToString()
        {
            return this.ToXML();
        }
        public string ToXML()
        {
            var stringwriter = new System.IO.StringWriter();
            var serializer = new XmlSerializer(this.GetType());
            serializer.Serialize(stringwriter, this);
            return stringwriter.ToString();
        }

        
    }

    [Serializable]
    public class Expression
    {
        [XmlAttribute(
            AttributeName = "Operator",
            DataType = "string")]
        public ExpressionType Op;
        [XmlText]
        public string Text;

        public Expression(string Text, ExpressionType Op) {
            this.Text = Text;
            this.Op = Op;
        }

    }

    public class ExpressionType
    {
        private ExpressionType(string value) { Value = value; }

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

    }

    public class Operator
    {
        private Operator(string value) { Value = value; }

        public string Value { get; set; }

        public static Operator Or { get { return new Operator("Or"); } }
        public static Operator And { get { return new Operator("And"); } }
    }

    [Serializable]
    public class Query
    {
        private List<Condition> condition;
        private List<Field> field;
        [XmlElement(
            DataType = "Field",
            ElementName = "Field",
            Form = XmlSchemaForm.Unqualified,
            IsNullable = true,
            Order = 1,
            Type = typeof(Field)
            )]
        public List<Field> Field { get => field; set => field = value; }
        [XmlElement(
            DataType = "Condition",
            ElementName = "Condition",
            Form = XmlSchemaForm.Unqualified,
            IsNullable = true,
            Order = 2,
            Type = typeof(Condition)
            )]
        public List<Condition> Condition { get => condition; set => condition = value; }

        public Query(){}
        public Query(List<Field> field)
        {
            this.field = field;
        }
        public Query(List<Condition> condition)
        {
            this.condition = condition;
        }
    }
    [Serializable]
    public class Field
    {
        private Expression op;

        [XmlText]
        public string Text;
        [XmlAttribute(
            AttributeName = "Expression",
            DataType = "Expression"
            )]
        public Expression Op { get => op; set => op = value; }
        
        public Field(string Text, Expression Op)
        {
            this.Text = Text;
            this.op = Op;
        }
    }
    [Serializable]
    public class Condition
    {
        private Operator isOr;
        [XmlAttribute(
            AttributeName = "Operator",
            DataType = "Operator"
            )]
        public Operator Operator { get => isOr; set => isOr = value; }

        private List<Condition> condition;
        private List<Field> field;
        [XmlElement(
            DataType = "Field",
            ElementName = "Field",
            Form = XmlSchemaForm.Unqualified,
            IsNullable = true,
            Order = 1,
            Type = typeof(Field)
            )]
        public List<Field> Fields { get => field; set => field = value; }
        [XmlElement(
            DataType = "Condition",
            ElementName = "Condition",
            Form = XmlSchemaForm.Unqualified,
            IsNullable = true,
            Order = 2,
            Type = typeof(Condition)
            )]
        public List<Condition> Conditions { get => condition; set => condition = value; }

        public Condition(Operator Operator)
        {
            this.Operator = Operator;
        }

        public Condition(Operator Operator, List<Field> field)
        {
            this.Operator = Operator;
            this.field.AddRange(field);
        }

        public Condition(Operator Operator, List<Condition> condition)
        {
            this.Operator = Operator;
            this.condition.AddRange(condition);
        }
    }
}
