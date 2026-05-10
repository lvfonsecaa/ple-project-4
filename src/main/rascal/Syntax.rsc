module Syntax

layout Layout = WS* !>> [\ \t\n\r#];

lexical WS
  = [\ \t\n\r]
  | @category="Comment" "#" ![\n]* $;


start syntax Module
  = moduleDef: "defmodule" Identifier Import* Definition* "end";

syntax Import = importDef: "using" Identifier;

syntax Definition
  = defSpace: SpaceDef
  | defOperator: OperatorDef
  | defVar: VarDef
  | defRule: RuleDef
  | defValue: ValueDef
  | defData: DataDef
  | defExpression: ExpressionDef;

syntax SpaceDef
  = simpleSpace: "defspace" Identifier "end"
  | subspace: "defspace" Identifier "\<" Identifier "end";

syntax Type
  = intTypeDef: "Int"
  | boolTypeDef: "Bool"
  | charTypeDef: "Char"
  | stringTypeDef: "String"
  | setTypeDef: "Set" "[" Type "]"
  | typeDef: Identifier;

syntax OperatorDef
  = operatorDefDef: "defoperator" Identifier ":" OperatorSignature "[" Attribute+ "]" "end"
  | operatorDefNoAttrs: "defoperator" Identifier ":" OperatorSignature "end";

syntax OperatorSignature = operatorSignatureDef: {Type "-\>"}+;

syntax Attribute
  = attrName: Identifier
  | attrPair: Identifier ":" Identifier;

syntax VarDef = varDefDef : "defvar" {VarDecl ","}+ "end";

syntax VarDecl = varDeclDef : Identifier ":" Type;

syntax ValueDef = valueDefDef : "defvalue" Identifier ":" Type "=" Expression "end";

syntax DataDef = dataDefDef : "defdata" Identifier ":" "Set" "[" Type "]" "=" "{" {Identifier ","}* "}" "end";

syntax RuleDef = ruleDefDef : "defrule" OperatorApplication "-\>" OperatorApplication "end";

syntax OperatorApplication
  = prefixOpApp: PrefixApplication
  | infixOpApp: InfixApplication;

syntax PrefixApplication = prefixApplicationDef : "(" Identifier SimpleTerm+ ")";

syntax InfixApplication = infixApplicationDef : SimpleTerm InfixOperator SimpleTerm;

syntax SimpleTerm
  = simpleIdentifier: Identifier
  | groupedSimpleTerm: "(" Expression ")"; 

syntax InfixOperator
  = infixIdentifier: Identifier
  | inKeyword: "in";

syntax ExpressionDef = expressionDefDef : "defexpression" Expression "end";

syntax Expression
  = quantifiedExpr: QuantifiedExpression
  | equivalenceExpr: EquivalenceExpression;

syntax EquivalenceExpression
  = implicationOnly: ImplicationExpression
  | equivalenceChain: ImplicationExpression EquivalenceOp EquivalenceExpression;

syntax EquivalenceOp
  = asciiEquiv: "===";

syntax ImplicationExpression
  = orOnly: OrExpression
  | implicationChain: OrExpression "=\>" ImplicationExpression;

syntax OrExpression
  = andOnly: AndExpression
  | orChain: AndExpression "or" OrExpression;

syntax AndExpression
  = comparisonOnly: ComparisonExpression
  | andChain: ComparisonExpression "and" AndExpression;

syntax ComparisonExpression
  = additiveOnly: AdditiveExpression
  | comparisonExpr: AdditiveExpression ComparisonOp AdditiveExpression;

syntax AdditiveExpression
  = multiplicativeOnly: MultiplicativeExpression
  | addChain: MultiplicativeExpression AdditiveOp AdditiveExpression;

syntax AdditiveOp
  = plus: "+"
  | minus: "-";

syntax MultiplicativeExpression
  = powerOnly: PowerExpression
  | multiplyChain: PowerExpression MultiplicativeOp MultiplicativeExpression;

syntax MultiplicativeOp
  = times: "*"
  | divide: "/"
  | modulo: "%";

syntax PowerExpression
  = unaryOnly: UnaryExpression
  | powerChain: UnaryExpression "**" PowerExpression;

syntax UnaryExpression
  = unaryNegation: "neg" UnaryExpression
  | primaryOnly: PrimaryExpression;

syntax PrimaryExpression
  = operatorPrimary: OperatorApplication
  | identifierPrimary: Identifier
  | trueLiteralPrimary: "true"
  | falseLiteralPrimary: "false"
  | intLiteralPrimary: IntLiteral
  | charLiteralPrimary: CharLiteral
  | stringLiteralPrimary: StringLiteral
  | groupedPrimary: "(" Expression ")";

syntax ComparisonOp = eq:"="|lt:"\<"|gt:"\>"|le:"\<="|ge:"\>="|ne:"\<\>";

syntax QuantifiedExpression = quantifiedExpressionDef : Quantifier Identifier "in" Type "." Expression;

syntax Quantifier
  = forallQ: "forall"
  | existsQ: "exists";

syntax IntLiteral = intLiteral : Number Number*;

syntax FloatLiteral = floatLiteralDef : Number Number* "." Number Number*;

lexical Number = [0-9];

lexical CharLiteral = "@" [a-zA-Z0-9];

lexical StringLiteral = "\"" ![\"]* "\"";

lexical Identifier
  = ([a-zA-Z] [a-zA-Z0-9\-]* !>> [a-zA-Z0-9\-]) \ Reserved;

keyword Reserved
  = "defmodule"
  | "using"
  | "defspace"
  | "defoperator"
  | "defvar"
  | "defrule"
  | "defvalue"
  | "defdata"
  | "defexpression"
  | "defer"
  | "end"
  | "in"
  | "forall"
  | "exists"
  | "Int"
  | "Bool"
  | "Char"
  | "String"
  | "true"
  | "false"
  | "neg"
  | "or"
  | "and";
