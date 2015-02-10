import 'package:ons/script/types.dart';
import 'package:petitparser/petitparser.dart';

class NScripterGrammar extends GrammarParser {
  NScripterGrammar() : super(new NScripterGrammarDefinition());
}

class NScripterGrammarDefinition extends GrammarDefinition { 
  start() => ref(statement);
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
    Parser subscript = (char('[') & ref(constant, int).trim() & char(']')).pick(1);
    Map<Type, String> prefixes = {
      double: '%',
      String: '\$',
      List:   '?'
    };
    return
      char(prefixes[type]).seq(ref(constant, int)).pick(1)
        .seq(subscript.separatedBy(whitespace(), includeSeparators: false).trim())
        .map((list) => new Variable(type, list[0], list[1]));
  }

  constant(Type type) {
    Parser parser;
    switch (type) {
      case int:
        parser = ref(integer).or(ref(name));
        break;
      case double:
        parser =
          (char('+') | char('-')).optional()
            .seq(ref(digits))
            .seq(char('.').seq(ref(digits)).optional())
            .flatten()
            .map(double.parse);
        break;
      case String:
        parser = (char('"') & char('"').neg().star().flatten() & char('"')).pick(1);
        break;
    }
    return parser.map((value) => new Constant(type, value));
  }

  expression() {
    ExpressionBuilder builder = new ExpressionBuilder();
    
    builder.group()
      ..primitive(ref(variable, double))
      ..primitive(ref(variable, String))
      ..primitive(ref(variable, List))
      ..primitive(ref(constant, int))
      ..primitive(ref(constant, double))
      ..primitive(ref(constant, String));
    
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
      (string('fchk') & whitespace().plus() & ref(expression)).pick(2).map((a) => new FCHK(a)) |
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
