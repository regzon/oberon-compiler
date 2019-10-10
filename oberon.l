%option noyywrap

%{
    #include "oberon.tab.h"
%}

%%

[ \n\t]+	{ /* ignore */ }
MODULE		{ return MODULE; }

%%
