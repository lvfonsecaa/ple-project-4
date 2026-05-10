module Main

import AST;
import Checker;
import Interpreter;
import IO;
import ParseTree;
import Syntax;
import TypePalChecker;

Tree parseProgram(loc file) = parse(#start[Module], readFile(file)).top;

Module programAst(loc file) = implode(#Module, parseProgram(file));

void runProgram(loc file) {
    Tree pt = parseProgram(file);
    Module ast = implode(#Module, pt);

    println("=== VeriLang ===");
    println("Input: <file>");
    println("ParseTree OK");
    println("AST OK");

    println("\n=== Type Checking ===");
    messages = checkWithTypePal(pt);
    if (messages != []) {
        println("TypePal messages:");
        for (m <- messages) {
            println(" - <m>");
        }
    }

    if (!checkModule(ast)) {
        println("Type checking failed");
        return;
    }
    println("Type checking passed");

    println("\n=== Interpretation ===");
    println("Result: <showValue(evalModule(ast))>");
}

void main() {
    runProgram(|cwd:///instance/demo.vl|);
}
