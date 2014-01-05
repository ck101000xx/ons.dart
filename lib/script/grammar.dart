import 'types.dart'
class NscripterGrammar extends CompositeParser {
  @override
  void initialize() {
    def('start', ref('statement').star().end());
    _newline();
    _whitespace();
    _expression();
    _statement();
  }
  void _newline() {
    def('newline', Token.newlineParser());
  }
  void _whitespace() {
    def('whitespace',
        (ref('newline').not() & whitespace()) |
        ref('comment') |
        (ref('newline') & char('/')));
    def('comment', char(';') & ref('newline').neg().star());
  }
  void _expression() {
    Parser digits = digit().plus().flatten();
    Parser signed = char('+').or(char('-')).optional().seq(p).flatten();
    Parser integer = (digits).map(int.parse);
    Parser number = (signed & (char('.') & digits).flatten().optional()).flatten().map((s) => new Number(double.parse(s)));
    Parser numberVariable = (char('%') & integer).pick(1).map((i) => new NumberVariable(i));
    Parser stringVariable = (char('$') & letter().or(digit()).or('_').plus().flatten()).pick(1).map((s) => new StringVariable(s));
    Parser arrayVariable = ((char('?') & integer).pick(1) & (char('[') & integer & char(']')).pick(1).star()).map((l) => new ArrayVariable(l[0], l[1]))
  }
  void _statement() {
    def('statement seperator', char(':') | (ref('newline') & char('/').not()));
    def('label', char('*').seq(ref('newline').neg().star()).seq('newline');
  }
}