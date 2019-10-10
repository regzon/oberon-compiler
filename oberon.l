%option noyywrap

%{
    #include <string.h>
    #include "oberon.tab.h"

    int parseIdOrKeyword(char*);
%}

digit	[0-9]
letter	[A-Za-z]

%%

[ \n\t]+						{ /* ignore */ }
{letter}({digit}|{letter})*		{ return parseIdOrKeyword(yytext); }

%%

struct Keyword {
    int token;
    char* name;
};

struct Keyword keywords[] = {
    {MODULE, "MODULE"},
    {ARRAY, "ARRAY"},
    {T_BEGIN, "BEGIN"},
    {BY, "BY"},
    {CASE, "CASE"},
    {CONST, "CONST"},
    {DIV, "DIV"},
    {DO, "DO"},
    {ELSE, "ELSE"},
    {ELSIF, "ELSIF"},
    {END, "END"},
    {EXIT, "EXIT"},
    {FOR, "FOR"},
    {IF, "IF"},
    {IMPORT, "IMPORT"},
    {IN, "IN"},
    {IS, "IS"},
    {LOOP, "LOOP"},
    {MOD, "MOD"},
    {NIL, "NIL"},
    {OF, "OF"},
    {OR, "OR"},
    {POINTER, "POINTER"},
    {PROCEDURE, "PROCEDURE"},
    {RECORD, "RECORD"},
    {REPEAT, "REPEAT"},
    {RETURN, "RETURN"},
    {THEN, "THEN"},
    {TO, "TO"},
    {TYPE, "TYPE"},
    {UNTIL, "UNTIL"},
    {VAR, "VAR"},
    {WHILE, "WHILE"},
    {WITH, "WITH"},
    {BOOLEAN, "BOOLEAN"},
    {CHAR, "CHAR"},
    {FALSE, "FALSE"},
    {INTEGER, "INTEGER"},
    {NEW, "NEW"},
    {REAL, "REAL"},
    {TRUE, "TRUE"}
};

int parseIdOrKeyword(char* parsed_string) {
    int keywords_num = sizeof(keywords) / sizeof(struct Keyword);
    for (int i = 0; i < keywords_num; i++) {
        if (strcmp(parsed_string, keywords[i].name) == 0) {
            return keywords[i].token;
        }
    }

    yylval.string = (char *)malloc(strlen(parsed_string));
    strcpy(yylval.string, parsed_string);
    return IDENTIFIER;
}
