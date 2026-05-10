module TypePalChecker

import Message;
import ParseTree;
import Syntax;
extend analysis::typepal::TypePal;

data AType
  = intT()
  | boolT()
  | charT()
  | stringT()
  | namedT(str name)
  | setT(AType elem);

data IdRole = valueId();

void collect(current: (Module) `defmodule <Identifier _> <Import* _> <Definition* defs> end`, Collector c) {
  collect(defs, c);
}

void collect(current: (VarDef) `defvar <{VarDecl ","}+ decls> end`, Collector c) {
  collect(decls, c);
}

void collect(current: (VarDecl) `<Identifier name> : <Type ty>`, Collector c) {
  c.define("<name>", valueId(), current, defType(ty));
  collect(ty, c);
}

void collect(current: (ValueDef) `defvalue <Identifier name> : <Type ty> = <Expression expr> end`, Collector c) {
  c.define("<name>", valueId(), current, defType(ty));
  c.requireEqual(ty, expr, error(current, "Expected %t but found %t", ty, expr));
  collect(ty, expr, c);
}

void collect(current: (DataDef) `defdata <Identifier _> : Set [ <Type elemType> ] = { <{Identifier ","}* members> } end`, Collector c) {
  for (member <- members) {
    c.use(member, {valueId()});
    c.requireEqual(member, elemType, error(member, "Data element should have type %t, found %t", elemType, member));
  }
  collect(elemType, members, c);
}

void collect(current: (Type) `Int`, Collector c) = c.fact(current, intT());
void collect(current: (Type) `Bool`, Collector c) = c.fact(current, boolT());
void collect(current: (Type) `Char`, Collector c) = c.fact(current, charT());
void collect(current: (Type) `String`, Collector c) = c.fact(current, stringT());
void collect(current: (Type) `<Identifier name>`, Collector c) = c.fact(current, namedT("<name>"));

void collect(current: (Type) `Set [ <Type elemType> ]`, Collector c) {
  c.calculate("set type", current, [elemType], AType(Solver s) {
    return setT(s.getType(elemType));
  });
  collect(elemType, c);
}

void collect(current: (PrimaryExpression) `<Identifier name>`, Collector c) = c.use(name, {valueId()});
void collect(current: (PrimaryExpression) `true`, Collector c) = c.fact(current, boolT());
void collect(current: (PrimaryExpression) `false`, Collector c) = c.fact(current, boolT());
void collect(current: (PrimaryExpression) `<IntLiteral _>`, Collector c) = c.fact(current, intT());
void collect(current: (PrimaryExpression) `<CharLiteral _>`, Collector c) = c.fact(current, charT());
void collect(current: (PrimaryExpression) `<StringLiteral _>`, Collector c) = c.fact(current, stringT());

void collect(current: (Expression) `<EquivalenceExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (Expression) `<QuantifiedExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (QuantifiedExpression) `<Quantifier _> <Identifier name> in <Type ty> . <Expression body>`, Collector c) {
  c.define("<name>", valueId(), name, defType(ty));
  collect(ty, body, c);
}

void collect(current: (EquivalenceExpression) `<ImplicationExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (ImplicationExpression) `<OrExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (OrExpression) `<AndExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (AndExpression) `<ComparisonExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (ComparisonExpression) `<AdditiveExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (AdditiveExpression) `<MultiplicativeExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (MultiplicativeExpression) `<PowerExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (PowerExpression) `<UnaryExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (UnaryExpression) `<PrimaryExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

void collect(current: (UnaryExpression) `neg <UnaryExpression expr>`, Collector c) {
  c.fact(current, expr);
  collect(expr, c);
}

bool isError(error(_, _)) = true;
default bool isError(Message _) = false;

list[Message] checkWithTypePal(Tree pt) =
  [m | m <- getMessages(collectAndSolve(pt)), isError(m)];
