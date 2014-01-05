typedef Script = List<Statement>
class Expression {
}
class Variable implements Expression {
}
class Constant<T> implements Expression {
  T value;
  Constant(v) : value(v) {
  }
}
class Statement {
}
class ControlStatement implements Statement {
}
class Label implements ControlStatement {
  final String name;
  Label(String str) : name(str) {
  }
}
class If implements ControlStatement {
  final Expression expression;
  final Statement statement;
  If(Expression e, Statement s) : expression(e) : statement(s) {
  }
}
