module AST

data Module
  = moduleDef(str name, list[Import] imports, list[Definition] body);

data Import
  = importDef(str name);

data Definition
  = defSpace(SpaceDef space)
  | defOperator(OperatorDef op)
  | defVar(VarDef vars)
  | defRule(RuleDef rule)
  | defValue(ValueDef valueDefn)
  | defData(DataDef dataDecl)
  | defExpression(ExpressionDef expr);

data SpaceDef
  = simpleSpace(str name)
  | subspace(str name, str parent);

data Type
  = intTypeDef()
  | boolTypeDef()
  | charTypeDef()
  | stringTypeDef()
  | setTypeDef(Type elemType)
  | typeDef(str name);

data OperatorDef
  = operatorDefDef(str name, OperatorSignature sig, list[Attribute] attrs)
  | operatorDefNoAttrs(str name, OperatorSignature sig);

data OperatorSignature
  = operatorSignatureDef(list[Type] parts);

data Attribute
  = attrName(str name)
  | attrPair(str key, str val);

data VarDef
  = varDefDef(list[VarDecl] decls);

data VarDecl
  = varDeclDef(str name, Type ty);

data ValueDef
  = valueDefDef(str name, Type ty, Expression expr);

data DataDef
  = dataDefDef(str name, Type elemType, list[str] members);

data RuleDef
  = ruleDefDef(OperatorApplication lhs, OperatorApplication rhs);

data OperatorApplication
  = prefixOpApp(PrefixApplication prefixApp)
  | infixOpApp(InfixApplication infixApp);

data PrefixApplication
  = prefixApplicationDef(str op, list[SimpleTerm] args);

data InfixApplication
  = infixApplicationDef(SimpleTerm left, InfixOperator op, SimpleTerm right);

data SimpleTerm
  = simpleIdentifier(str name)
  | groupedSimpleTerm(Expression expr);

data InfixOperator
  = infixIdentifier(str name)
  | inKeyword();

data ExpressionDef
  = expressionDefDef(Expression expr);

data Expression
  = quantifiedExpr(QuantifiedExpression q)
  | equivalenceExpr(EquivalenceExpression e);

data EquivalenceExpression
  = implicationOnly(ImplicationExpression expr)
  | equivalenceChain(ImplicationExpression left, EquivalenceOp op, EquivalenceExpression right);

data EquivalenceOp
  = asciiEquiv()
  | unicodeEquiv();

data ImplicationExpression
  = orOnly(OrExpression expr)
  | implicationChain(OrExpression left, ImplicationExpression right);

data OrExpression
  = andOnly(AndExpression expr)
  | orChain(AndExpression left, OrExpression right);

data AndExpression
  = comparisonOnly(ComparisonExpression expr)
  | andChain(ComparisonExpression left, AndExpression right);

data ComparisonExpression
  = additiveOnly(AdditiveExpression expr)
  | comparisonExpr(AdditiveExpression left, ComparisonOp op, AdditiveExpression right);

data AdditiveExpression
  = multiplicativeOnly(MultiplicativeExpression expr)
  | addChain(MultiplicativeExpression left, AdditiveOp op, AdditiveExpression right);

data AdditiveOp
  = plus()
  | minus();

data MultiplicativeExpression
  = powerOnly(PowerExpression expr)
  | multiplyChain(PowerExpression left, MultiplicativeOp op, MultiplicativeExpression right);

data MultiplicativeOp
  = times()
  | divide()
  | modulo();

data PowerExpression
  = unaryOnly(UnaryExpression expr)
  | powerChain(UnaryExpression left, PowerExpression right);

data UnaryExpression
  = unaryNegation(UnaryExpression negated)
  | primaryOnly(PrimaryExpression primary);

data PrimaryExpression
  = operatorPrimary(OperatorApplication app)
  | identifierPrimary(str name)
  | trueLiteralPrimary()
  | falseLiteralPrimary()
  | intLiteralPrimary(str text)
  | charLiteralPrimary(str text)
  | stringLiteralPrimary(str text)
  | groupedPrimary(Expression expr);

data ComparisonOp
  = eq()
  | lt()
  | gt()
  | le()
  | ge()
  | ne();

data QuantifiedExpression
  = quantifiedExpressionDef(Quantifier q, str var, Type ty, Expression body);

data Quantifier
  = forallQ()
  | existsQ();
