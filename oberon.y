%{
    #include <stdio.h>
    #include <stdlib.h>

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char* s);
%}

%union {
    char* string;
}

%token <string> IDENTIFIER

%token MODULE ARRAY T_BEGIN BY CASE CONST DIV DO ELSE ELSIF
%token END EXIT FOR IF IMPORT IN IS LOOP MOD NIL TRUE
%token OF OR POINTER PROCEDURE RECORD REPEAT RETURN THEN
%token TO TYPE UNTIL VAR WHILE WITH BOOLEAN CHAR FALSE
%token INTEGER NEW REAL

%start CompilationUnit

%%

CompilationUnit
    : MODULE IDENTIFIER ModuleDeclaration { printf("%s\n", $2); }
    ;

ModuleDeclaration
    : ImportList T_BEGIN ModuleBody END { printf("Inside ModuleDeclaration\n"); }
    ;

ImportList
    : IMPORT IDENTIFIER { printf("%s\n", $2); }
    | /* empty */
    ;

ModuleBody
    : /* empty */
    ;

%%

int main() {
    yyin = stdin;
    yyparse();
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
