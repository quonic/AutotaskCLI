# Example use case of the QueryXML

First create a QueryXML object

```
private QueryXML sXML = new QueryXML()
{
    Entity = "Ticket"
};
```

Then create the Query object with our fields and conditions
Below is for fields only

``` 
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
```

Below is for fields in conditions

```
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
```

Then to convert the object to a Query XML string

```
sXML.ToXML()
```