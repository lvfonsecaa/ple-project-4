# VeriLang Part 3

This version extends the Part 2 VeriLang project with executable typed programs, a small TypePal layer, and a simple static checker.

## Main changes

1. The grammar was extended with:
   - primitive typed values: `Int`, `Bool`, `Char`, `String`
   - `defvalue` declarations with explicit type annotations
   - `defdata` declarations for typed sets
   - executable literals (`true`, `false`, integer, char, string)
   - support for `.vl` files in addition to `.vlg`

2. The AST was updated to mirror the new syntax:
   - new `Type` alternatives for primitive and set types
   - new `ValueDef` and `DataDef` nodes
   - new literal nodes in expressions

3. TypePal was installed as a Maven dependency in `pom.xml` and connected through `TypePalChecker.rsc`:
   - defines value identifiers for TypePal
   - checks simple annotated values
   - checks that `defdata` elements refer to existing values

4. The remaining static checking rules are implemented directly in `Checker.rsc` so the code remains small and easy to follow:
   - verifies value declarations against their annotations
   - verifies arithmetic and boolean operator usage
   - verifies quantified expressions return `Bool`
   - verifies every `defdata` member exists and matches the declared element type

5. A new `Interpreter.rsc` module executes the last `defexpression` of a module and prints the result.

6. `Main.rsc` now parses a `.vl` file, builds the AST with `implode`, runs the TypePal layer and the checker, and only executes the program when the checker succeeds.

## Source of the solution

The starting point was the existing Part 2 project in this repository. No external student solution was copied into the codebase.

TypePal is included through Maven and used in a small module instead of a large framework-heavy checker. The rest of the checker is intentionally direct, because the rubric focuses on type annotations, type correspondence, and the data element existence rule.

## Fixes relative to the previous iteration

- preserved the earlier grammar fixes for `neg`, arithmetic precedence, and direct AST implosion
- added a real parser/execution pipeline instead of only printing parse trees
- introduced explicit typing and semantic validation so programs can be checked before execution
