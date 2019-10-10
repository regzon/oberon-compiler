all: oberon

oberon.tab.c oberon.tab.h: oberon.y
	bison -d oberon.y

lex.yy.c: oberon.l oberon.tab.h
	flex oberon.l

oberon: lex.yy.c oberon.tab.c oberon.tab.h
	gcc -o oberon.out oberon.tab.c lex.yy.c

clean:
	rm oberon oberon.tab.c lex.yy.c oberon.tab.h
