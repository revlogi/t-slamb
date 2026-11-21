<expr> ::= <fun> | <app>

<fun> ::= "\" <names> "." <expr>

<app> ::= <atom> { <atom> }

<atom> ::= <name>
| <val>
| "(" <expr> ")"

<names> ::= <name> { <name> }

<val> ::= Number | Boolean

<name> ::= Identifier
