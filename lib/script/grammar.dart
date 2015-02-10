import 'package:ons/script/types.dart';
import 'package:petitparser/petitparser.dart';


class NScripterGrammarDefinition extends GrammarDefinition { 
  start() => ref(statement).star().end();
  newline() => Token.newlineParser();
  comment() => char(';') & ref(newline).neg().star();
  white() =>
    ref(newline).not() & whitespace() |
    ref(comment) |
    ref(newline) & char('/');
  digits() => digit().plus().flatten();
  integer() => string('0x').optional().seq(ref(digits)).flatten().map(int.parse);
  name() =>
    (letter() | char('_'))
      .seq((digit() | letter() | char('_')).star())
      .flatten();

  variable(Type type) {
    Map<Type, String> prefixes = {
      double: '%',
      String: '\$',
      List:   '?'
    };
    return (char(prefixes[type]) & ref(integer).or(ref(name))).pick(1);
  }

  expression() {
    Parser number =
      (char('+') | char('-')).optional()
        .seq(ref(digits))
        .seq(char('.').seq(ref(digits)).optional())
        .flatten()
        .map(double.parse);

    Parser string = (char('"') & char('"').neg().star().flatten() & char('"')).pick(1);
    
    ExpressionBuilder builder = new ExpressionBuilder();
    
    builder.group()
      ..primitive(number.or(ref(integer)).map((n) => new Constant(n)).trim())
      ..primitive(string.map((n) => new Constant(n)).trim());
    
    builder.group()
      ..left(char('*').trim(), (a, op, b) => new Mut(a, b))
      ..left(char('/').trim(), (a, op, b) => new Div(a, b));
    
    builder.group()
      ..left(char('+').trim(), (a, op, b) => new Add(a, b))
      ..left(char('-').trim(), (a, op, b) => new Sub(a, b));

    return builder.build();
  }

  condition() {
    Parser unary(Parser operator, fn) =>
      (ref(expression) &  operator.trim() & ref(expression)).map((list) => fn(list[0], list[1]));

    Parser cond =
      (string('fchk') & whitespace().plus() & ref(expression)).map((a) => new FCHK(a)) |
      unary(char('=').seq(char('=').optional()).trim(), (a, b) => new EQ(a, b)) |
      unary(string('!=').or(string('<>')).trim(), (a, b) => new NE(a, b)) |
      unary(string('>=').trim(), (a, b) => new GTE(a, b)) |
      unary(string('<=').trim(), (a, b) => new LTE(a, b)) |
      unary(char('>').trim(), (a, b) => new GT(a, b)) |
      unary(char('<').trim(), (a, b) => new LT(a, b));

    ExpressionBuilder builder = new ExpressionBuilder();

    builder.group().primitive(cond.trim());
    
    builder.group()
       .left(char('&').seq(char('&').optional()).trim(), (a, op, b) => new And(a, b));
        
    return builder.build();  
  }

  label() => char('*').seq(ref(name)).pick(1).map((name) => new Label(name));
}