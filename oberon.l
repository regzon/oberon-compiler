%option noyywrap

%{
    #include <string.h>
    #include "oberon.tab.h"

    int parseIdOrKeyword(char*);
    int parseInteger(char*);
    int parseHexInteger(char*);
    int parseHexString(char*);
    int parseReal(char*);
    int parseString(char*);
%}

digit		[0-9]
hexDigit	[0-9A-F]
letter		[A-Za-z]

%%

[ \n\t]+								{ /* ignore */ }
{digit}+								{ return parseInteger(yytext); }
{hexDigit}+"H"							{ return parseHexInteger(yytext); }
{hexDigit}+"X"							{ return parseHexString(yytext); }
{digit}+"."{digit}*(E[+-]?{digit}+)?	{ return parseReal(yytext); }
{letter}({digit}|{letter})*				{ return parseIdOrKeyword(yytext); }
\"[^\"\n]*\"							{ return parseString(yytext); }

"+"		{ return O_ADD; }
"-"		{ return O_SUB; }
"*"		{ return O_MUL; }
"/"		{ return O_DIV; }
"~"		{ return O_NOT; }
"&"		{ return O_AND; }
"."		{ return D_DOT; }
","		{ return D_COM; }
":"		{ return D_COL; }
";"		{ return D_SEM; }
"|"		{ return D_PIP; }
"("		{ return D_LBR; }
")"		{ return D_RBR; }
"["		{ return D_LSQBR; }
"]"		{ return D_RSQBR; }
"{"		{ return D_LCURBR; }
"}"		{ return D_RCURBR; }
".."	{ return D_DDOT; }
">"		{ return O_GT; }
">="	{ return O_GTE; }
"<"		{ return O_LT; }
"<="	{ return O_LTE; }
"#"		{ return O_NOTEQ; }
"="		{ return O_EQ; }
"^"		{ return O_POINT; }
":="	{ return O_ASS; }



%%

struct Keyword {
    int token;
    char* name;
};

struct Keyword keywords[] = {
    {K_MODULE, "MODULE"},
    {K_ARRAY, "ARRAY"},
    {K_BEGIN, "BEGIN"},
    {K_BY, "BY"},
    {K_CASE, "CASE"},
    {K_CONST, "CONST"},
    {K_DIV, "DIV"},
    {K_DO, "DO"},
    {K_ELSE, "ELSE"},
    {K_ELSIF, "ELSIF"},
    {K_END, "END"},
    {K_EXIT, "EXIT"},
    {K_FOR, "FOR"},
    {K_IF, "IF"},
    {K_IMPORT, "IMPORT"},
    {K_IN, "IN"},
    {K_IS, "IS"},
    {K_LOOP, "LOOP"},
    {K_MOD, "MOD"},
    {K_NIL, "NIL"},
    {K_OF, "OF"},
    {K_OR, "OR"},
    {K_POINTER, "POINTER"},
    {K_PROCEDURE, "PROCEDURE"},
    {K_RECORD, "RECORD"},
    {K_REPEAT, "REPEAT"},
    {K_RETURN, "RETURN"},
    {K_THEN, "THEN"},
    {K_TO, "TO"},
    {K_TYPE, "TYPE"},
    {K_UNTIL, "UNTIL"},
    {K_VAR, "VAR"},
    {K_WHILE, "WHILE"},
    {K_WITH, "WITH"},
    {K_TRUE, "TRUE"},
    {K_FALSE, "FALSE"}
};

char* predefined_ind[] = {
    "BOOLEAN", "CHAR", "REAL",
    "INTEGER", "NEW"
};

int parseIdOrKeyword(char* parsed_string) {
    int keywords_num = sizeof(keywords) / sizeof(struct Keyword);
    for (int i = 0; i < keywords_num; i++) {
        if (strcmp(parsed_string, keywords[i].name) == 0) {
            return keywords[i].token;
        }
    }

    int predefined_num = sizeof(predefined_ind) / sizeof(char*);
    for (int i = 0; i < predefined_num; i++) {
        if (strcmp(parsed_string, predefined_ind[i]) == 0) {
            yylval.string = (char *)malloc(strlen(parsed_string));
            strcpy(yylval.string, parsed_string);
            return PREDEFINED_IDENTIFIER;
        }
    }

    yylval.string = (char *)malloc(strlen(parsed_string));
    strcpy(yylval.string, parsed_string);
    return IDENTIFIER;
}

int parseInteger(char* s) {
    return T_INTEGER;
}

int parseHexInteger(char* s) {
    return T_INTEGER;
}

int parseHexString(char* s) {
    return T_STRING;
}

int parseReal(char* s) {
    return T_REAL;
}

int parseString(char* s) {
    return T_STRING;
}
