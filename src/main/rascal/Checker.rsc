module Checker

import AST;
import IO;

alias TypeEnv = map[str, Type];

str showType(intTypeDef()) = "Int";
str showType(boolTypeDef()) = "Bool";
str showType(charTypeDef()) = "Char";
str showType(stringTypeDef()) = "String";
str showType(typeDef(name)) = name;
str showType(setTypeDef(elem)) = "Set[<showType(elem)>]";

bool sameType(intTypeDef(), intTypeDef()) = true;
bool sameType(boolTypeDef(), boolTypeDef()) = true;
bool sameType(charTypeDef(), charTypeDef()) = true;
bool sameType(stringTypeDef(), stringTypeDef()) = true;
bool sameType(typeDef(a), typeDef(b)) = a == b;
bool sameType(setTypeDef(a), setTypeDef(b)) = sameType(a, b);
default bool sameType(Type _, Type _) = false;

bool checkModule(moduleDef(_, _, defs)) {
  TypeEnv env = ();
  bool ok = true;

  for (d <- defs) {
    <env, ok> = checkDefinition(d, env, ok);
  }

  return ok;
}

tuple[TypeEnv, bool] checkDefinition(Definition d, TypeEnv env, bool ok) {
  switch (d) {
    case defVar(varDefDef(decls)): {
      for (varDeclDef(name, ty) <- decls) {
        env[name] = ty;
      }
      return <env, ok>;
    }

    case defValue(valueDefDef(name, ty, expr)): {
      Type found = typeOf(expr, env);
      if (!sameType(ty, found)) {
        println("Type error in <name>: expected <showType(ty)> but got <showType(found)>");
        ok = false;
      }
      env[name] = ty;
      return <env, ok>;
    }

    case defData(dataDefDef(name, elemType, members)): {
      for (member <- members) {
        if (!(member in env)) {
          println("Type error in data <name>: element <member> does not exist");
          ok = false;
        }
        else if (!sameType(env[member], elemType)) {
          println("Type error in data <name>: element <member> has type <showType(env[member])> but expected <showType(elemType)>");
          ok = false;
        }
      }
      env[name] = setTypeDef(elemType);
      return <env, ok>;
    }

    case defExpression(expressionDefDef(expr)): {
      Type found = typeOf(expr, env);
      if (!sameType(found, boolTypeDef())) {
        println("Type error: defexpression must be Bool but got <showType(found)>");
        ok = false;
      }
      return <env, ok>;
    }

    default:
      return <env, ok>;
  }
}

Type typeOf(Expression e, TypeEnv env) {
  switch (e) {
    case quantifiedExpr(quantifiedExpressionDef(_, name, ty, body)): {
      TypeEnv newEnv = env;
      newEnv[name] = ty;
      return typeOf(body, newEnv);
    }

    case equivalenceExpr(expr):
      return typeOf(expr, env);
  }

  return typeDef("Error");
}

Type typeOf(equivalenceChain(left, _, right), TypeEnv env) {
  if (!requireBool(typeOf(left, env), "equivalence") || !requireBool(typeOf(right, env), "equivalence")) {
    return typeDef("Error");
  }
  return boolTypeDef();
}

Type typeOf(implicationOnly(expr), TypeEnv env) = typeOf(expr, env);

Type typeOf(implicationChain(left, right), TypeEnv env) {
  if (!requireBool(typeOf(left, env), "implication") || !requireBool(typeOf(right, env), "implication")) {
    return typeDef("Error");
  }
  return boolTypeDef();
}

Type typeOf(orOnly(expr), TypeEnv env) = typeOf(expr, env);

Type typeOf(orChain(left, right), TypeEnv env) {
  if (!requireBool(typeOf(left, env), "or") || !requireBool(typeOf(right, env), "or")) {
    return typeDef("Error");
  }
  return boolTypeDef();
}

Type typeOf(andOnly(expr), TypeEnv env) = typeOf(expr, env);

Type typeOf(andChain(left, right), TypeEnv env) {
  if (!requireBool(typeOf(left, env), "and") || !requireBool(typeOf(right, env), "and")) {
    return typeDef("Error");
  }
  return boolTypeDef();
}

Type typeOf(comparisonOnly(expr), TypeEnv env) = typeOf(expr, env);

Type typeOf(additiveOnly(expr), TypeEnv env) = typeOf(expr, env);

Type typeOf(comparisonExpr(left, _, right), TypeEnv env) {
  Type lt = typeOf(left, env);
  Type rt = typeOf(right, env);

  if (!sameType(lt, rt)) {
    println("Type error: comparison between <showType(lt)> and <showType(rt)>");
    return typeDef("Error");
  }

  return boolTypeDef();
}

Type typeOf(multiplicativeOnly(expr), TypeEnv env) = typeOf(expr, env);

Type typeOf(addChain(left, _, right), TypeEnv env) {
  if (!requireInt(typeOf(left, env), "arithmetic") || !requireInt(typeOf(right, env), "arithmetic")) {
    return typeDef("Error");
  }
  return intTypeDef();
}

Type typeOf(powerOnly(expr), TypeEnv env) = typeOf(expr, env);

Type typeOf(multiplyChain(left, _, right), TypeEnv env) {
  if (!requireInt(typeOf(left, env), "arithmetic") || !requireInt(typeOf(right, env), "arithmetic")) {
    return typeDef("Error");
  }
  return intTypeDef();
}

Type typeOf(unaryOnly(expr), TypeEnv env) = typeOf(expr, env);

Type typeOf(powerChain(left, right), TypeEnv env) {
  if (!requireInt(typeOf(left, env), "power") || !requireInt(typeOf(right, env), "power")) {
    return typeDef("Error");
  }
  return intTypeDef();
}

Type typeOf(primaryOnly(expr), TypeEnv env) = typeOf(expr, env);

Type typeOf(unaryNegation(expr), TypeEnv env) {
  Type ty = typeOf(expr, env);
  if (sameType(ty, intTypeDef()) || sameType(ty, boolTypeDef())) {
    return ty;
  }

  println("Type error: neg expects Int or Bool but got <showType(ty)>");
  return typeDef("Error");
}

Type typeOf(identifierPrimary(name), TypeEnv env) {
  if (name in env) {
    return env[name];
  }

  println("Undefined identifier: <name>");
  return typeDef("Error");
}

Type typeOf(trueLiteralPrimary(), TypeEnv env) = boolTypeDef();
Type typeOf(falseLiteralPrimary(), TypeEnv env) = boolTypeDef();
Type typeOf(intLiteralPrimary(_), TypeEnv env) = intTypeDef();
Type typeOf(charLiteralPrimary(_), TypeEnv env) = charTypeDef();
Type typeOf(stringLiteralPrimary(_), TypeEnv env) = stringTypeDef();
Type typeOf(groupedPrimary(expr), TypeEnv env) = typeOf(expr, env);
Type typeOf(operatorPrimary(_), TypeEnv env) = boolTypeDef();

bool requireBool(Type ty, str where) {
  if (!sameType(ty, boolTypeDef())) {
    println("Type error: <where> expects Bool but got <showType(ty)>");
    return false;
  }
  return true;
}

bool requireInt(Type ty, str where) {
  if (!sameType(ty, intTypeDef())) {
    println("Type error: <where> expects Int but got <showType(ty)>");
    return false;
  }
  return true;
}
