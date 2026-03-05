/* Lexer */
%lex
%%
\s+                                  { /* skip whitespace */; }
\/\/[^\n]*                           { /* skip whitespace */; }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?  { return 'NUMBER';       }
"**"                                 { return 'OPOW';         }
[-+]                                 { return 'OPAD';         }
[*/]                                 { return 'OPMU';         }
"("                                  { return 'LPAREN';       }
")"                                  { return 'RPAREN';       }
<<EOF>>                              { return 'EOF';          }
.                                    { return 'INVALID';      }
/lex

/* Parser */
%start expressions
%token NUMBER OPAD OPMU OPOW LPAREN RPAREN

%%

expressions
    : expression EOF
        { return $expression; }
    ;

expression
    : expression OPAD term
        { $$ = operate($OPAD, $expression, $term); }
    | term
        { $$ = $term; }
    ;

term
    : term OPMU r
        { $$ = operate($OPMU, $term, $r); }
    | r
        { $$ = $r; }
    ;

r 
    : f OPOW r
        { $$ = operate($OPOW, $f, $r); }
    | f
        { $$ = $f; }
    ;

f   
    : NUMBER
        { $$ = Number(yytext); }
    | LPAREN expression RPAREN  
        { $$ = $expression; }
    ;
%%

function operate(op, left, right) {
    switch (op) {
        case '+': return left + right;
        case '-': return left - right;
        case '*': return left * right;
        case '/': return left / right;
        case '**': return Math.pow(left, right);
    }
}
