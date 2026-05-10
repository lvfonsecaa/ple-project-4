module Interpreter

import AST;
import String;

data Value
  = intV(int n)
  | boolV(bool b)
  | charV(str c)
  | stringV(str s);

alias Env = map[str, Value];

str showValue(intV(n)) = "<n>";
str showValue(boolV(b)) = "<b>";
str showValue(charV(c)) = c;
str showValue(stringV(s)) = s;

Value evalModule(moduleDef(_, _, defs)) {
  Env env = ();
  Value result = boolV(false);

  for (d <- defs) {
    switch (d) {
      case defValue(valueDefDef(name, _, expr)):
        env[name] = evalExpression(expr, env);

      case defExpression(expressionDefDef(expr)):
        result = evalExpression(expr, env);
    }
  }

  return result;
}

Value evalExpression(Expression e, Env env) {
  switch (e) {
    case quantifiedExpr(q):
      return evalQuantified(q, env);

    case equivalenceExpr(expr):
      return evalEquivalence(expr, env);
  }

  return boolV(false);
}

Value evalQuantified(quantifiedExpressionDef(forallQ(), name, _, body), Env env) {
  Env envTrue = env;
  Env envFalse = env;
  envTrue[name] = boolV(true);
  envFalse[name] = boolV(false);
  return boolV(asBool(evalExpression(body, envTrue)) && asBool(evalExpression(body, envFalse)));
}

Value evalQuantified(quantifiedExpressionDef(existsQ(), name, _, body), Env env) {
  Env envTrue = env;
  Env envFalse = env;
  envTrue[name] = boolV(true);
  envFalse[name] = boolV(false);
  return boolV(asBool(evalExpression(body, envTrue)) || asBool(evalExpression(body, envFalse)));
}

Value evalEquivalence(implicationOnly(expr), Env env) = evalImplication(expr, env);

Value evalEquivalence(equivalenceChain(left, _, right), Env env) =
  boolV(asBool(evalImplication(left, env)) == asBool(evalEquivalence(right, env)));

Value evalImplication(orOnly(expr), Env env) = evalOr(expr, env);

Value evalImplication(implicationChain(left, right), Env env) =
  boolV(!asBool(evalOr(left, env)) || asBool(evalImplication(right, env)));

Value evalOr(andOnly(expr), Env env) = evalAnd(expr, env);

Value evalOr(orChain(left, right), Env env) =
  boolV(asBool(evalAnd(left, env)) || asBool(evalOr(right, env)));

Value evalAnd(comparisonOnly(expr), Env env) = evalComparison(expr, env);

Value evalAnd(andChain(left, right), Env env) =
  boolV(asBool(evalComparison(left, env)) && asBool(evalAnd(right, env)));

Value evalComparison(additiveOnly(expr), Env env) = evalAdditive(expr, env);

Value evalComparison(comparisonExpr(left, op, right), Env env) {
  Value l = evalAdditive(left, env);
  Value r = evalAdditive(right, env);

  switch (op) {
    case eq(): return boolV(l == r);
    case ne(): return boolV(l != r);
    case lt(): return boolV(asInt(l) < asInt(r));
    case gt(): return boolV(asInt(l) > asInt(r));
    case le(): return boolV(asInt(l) <= asInt(r));
    case ge(): return boolV(asInt(l) >= asInt(r));
  }

  return boolV(false);
}

Value evalAdditive(multiplicativeOnly(expr), Env env) = evalMultiplicative(expr, env);

Value evalAdditive(addChain(left, plus(), right), Env env) =
  intV(asInt(evalMultiplicative(left, env)) + asInt(evalAdditive(right, env)));

Value evalAdditive(addChain(left, minus(), right), Env env) =
  intV(asInt(evalMultiplicative(left, env)) - asInt(evalAdditive(right, env)));

Value evalMultiplicative(powerOnly(expr), Env env) = evalPower(expr, env);

Value evalMultiplicative(multiplyChain(left, times(), right), Env env) =
  intV(asInt(evalPower(left, env)) * asInt(evalMultiplicative(right, env)));

Value evalMultiplicative(multiplyChain(left, divide(), right), Env env) =
  intV(asInt(evalPower(left, env)) / asInt(evalMultiplicative(right, env)));

Value evalMultiplicative(multiplyChain(left, modulo(), right), Env env) =
  intV(asInt(evalPower(left, env)) % asInt(evalMultiplicative(right, env)));

Value evalPower(unaryOnly(expr), Env env) = evalUnary(expr, env);

Value evalPower(powerChain(left, right), Env env) =
  intV(pow(asInt(evalUnary(left, env)), asInt(evalPower(right, env))));

Value evalUnary(primaryOnly(expr), Env env) = evalPrimary(expr, env);

Value evalUnary(unaryNegation(expr), Env env) {
  Value v = evalUnary(expr, env);
  switch (v) {
    case intV(n): return intV(-n);
    case boolV(b): return boolV(!b);
  }

  return boolV(false);
}

Value evalPrimary(identifierPrimary(name), Env env) {
  if (name in env) {
    return env[name];
  }

  return boolV(false);
}

Value evalPrimary(trueLiteralPrimary(), Env env) = boolV(true);
Value evalPrimary(falseLiteralPrimary(), Env env) = boolV(false);
Value evalPrimary(intLiteralPrimary(text), Env env) = intV(toInt(trim(text)));
Value evalPrimary(charLiteralPrimary(text), Env env) = charV(text);
Value evalPrimary(stringLiteralPrimary(text), Env env) = stringV(text);
Value evalPrimary(groupedPrimary(expr), Env env) = evalExpression(expr, env);
Value evalPrimary(operatorPrimary(_), Env env) = boolV(true);

int asInt(intV(n)) = n;
default int asInt(Value _) = 0;

bool asBool(boolV(b)) = b;
default bool asBool(Value _) = false;

int pow(int base, int exp) {
  int result = 1;
  for (_ <- [0 .. exp]) {
    result *= base;
  }
  return result;
}
