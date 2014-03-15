CFLAGS=-g
BISON=bison
FLEX=flex

parser: parser.o scanner.o parse_tree.o
	$(CC) -o parser scanner.o parser.o parse_tree.o liblist.a

parser.c: parser.y
	$(BISON) -d parser.y  -o parser.c

scanner.c: scanner.l
	$(FLEX)  -o scanner.c scanner.l

parse_tree.o: parse_tree.c
	$(CC) -c -o parse_tree.o parse_tree.c

clean:
	rm -f scanner.c scanner.o parser.c parser.o parser.h parse_tree.o parser

