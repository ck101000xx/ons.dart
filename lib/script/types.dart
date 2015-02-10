class Expression {
}
class Variable implements Expression {
  final Type type;
  final index;
  Variable(this.type, this.index);
}
class Constant implements Expression {
  final value;
  Constant(this.value);
}
class Add implements Expression {
  final Expression left, right;
  Add(this.left, this.right);
}
class Sub implements Expression {
  final Expression left, right;
  Sub(this.left, this.right);
}
class Mut implements Expression {
  final Expression left, right;
  Mut(this.left, this.right);
}
class Div implements Expression {
  final Expression left, right;
  Div(this.left, this.right);
}
class Condition {
}
class GT implements Condition {
  final Expression left, right;
  GT(this.left, this.right);  
}
class GTE implements Condition {
  final Expression left, right;
  GTE(this.left, this.right);  
}
class LT implements Condition {
  final Expression left, right;
  LT(this.left, this.right);  
}
class LTE implements Condition {
  final Expression left, right;
  LTE(this.left, this.right);  
}
class EQ implements Condition {
  final Expression left, right;
  EQ(this.left, this.right);  
}
class NE implements Condition {
  final Expression left, right;
  NE(this.left, this.right);  
}
class FCHK implements Condition {
  final Expression str;
  FCHK(this.str);  
}
class And implements Condition {
  final Condition left, right;
  And(this.left, this.right);  
}
class Statement {
}
class Block implements Statement {
  final List<Statement> statements;
  Block(this.statements);
}
class ControlStatement implements Statement {
}
class Label implements ControlStatement {
  final String name;
  Label(this.name);
}
class If implements ControlStatement {
  final Expression expression;
  final Statement statement;
  If(this.expression, this.statement);
}
