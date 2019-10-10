%{
    #include <stdio.h>
    #include <stdlib.h>

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char* s);
%}

%token MODULE

%start CompilationUnit

%%

CompilationUnit
    : MODULE { printf("MODULE\n"); }
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
