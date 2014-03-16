CFLAGS=-g
BISON=bison
FLEX=flex
INCLUDE=list/src
LIB=list/build

.PHONY: list clean

parser: parser.o scanner.o parse_tree.o list
	$(CC) -L$(LIB) -o parser scanner.o parser.o parse_tree.o -llist

parser.c: parser.y
	$(BISON) -d parser.y  -o parser.c

parser.o: parser.c
	$(CC) $(CFLAGS) -I$(INCLUDE) -c -o parser.o parser.c

scanner.c: scanner.l
	$(FLEX)  -o scanner.c scanner.l

scanner.o: scanner.c
	$(CC) $(CFLAGS) -I$(INCLUDE) -c -o scanner.o scanner.c

parse_tree.o: parse_tree.c
	$(CC) $(CFLAGS) -I$(INCLUDE) -c -o parse_tree.o parse_tree.c

list: list/src/list.c
	cd list; $(MAKE)

clean:
	rm -f scanner.c scanner.o parser.c parser.o parser.h parse_tree.o parser; \
cd list; $(MAKE) clean
