using System;
using System.Xml;
using System.Xml.Serialization;
using System.Collections.Generic;


namespace AutotaskCLI
{
    [Serializable]
    public class QueryXML
    {
        [XmlAttribute]
        public string Entity { get; set; }
        public Query Children { get; set; }

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
    public class Query
    {
        private List<object> items;

        public bool IsField;
        public bool IsCondition;
        public bool IsChild;
        public List<object> Items { get => items; set => items = value; }

        public Query()
        {
            this.IsCondition = false;
            this.IsField = false;
            this.IsChild = false;
            this.Items = new List<object>();
        }
        public Query(List<object> Children)
        {
            this.IsCondition = false;
            this.IsField = false;
            this.IsChild = false;
            this.Items = Children;
        }
    }

    public class Field : Query
    {
        public string Text;
        public Ops Op;
        public string Expression;


        public Field(string Text, Ops Op, string Expression)
        {
            this.Text = Text;
            this.Op = Op;
            this.Expression = Expression;
            base.IsField = true;

        }
    }

    public class Condition : Query
    {
        private bool isOr;

        public bool IsOr { get => isOr; set => isOr = value; }


        public Condition()
        {
            this.IsOr = false;
            base.IsCondition = true;
        }
        public Condition(bool IsOr)
        {
            this.IsOr = IsOr;
            base.IsCondition = true;
        }
        public void AddItem(Field SingleField)
        {
            base.Items.Add(SingleField);
        }
        public void AddItem(Condition SingleCondition)
        {
            base.Items.Add(SingleCondition);
        }
    }
}
