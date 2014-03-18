CFLAGS=-g -Wall -Wextra
BISON=bison
FLEX=flex
INCLUDE=list/src
LIB=list/build

.PHONY: list clean

npltohtml: parser.o scanner.o parse_tree.o generate_code.o list
	$(CC) -L$(LIB) -o $@ scanner.o parser.o parse_tree.o generate_code.o \
		-llist

parser.c: parser.y
	$(BISON) -d parser.y  -o parser.c

parser.o: parser.c
	$(CC) $(CFLAGS) -I$(INCLUDE) -c -o parser.o parser.c

scanner.c: scanner.l
	$(FLEX) -o scanner.c scanner.l

scanner.o: scanner.c
	$(CC) $(CFLAGS) -Wno-unused-function -I$(INCLUDE) -c -o scanner.o scanner.c

parse_tree.o: parse_tree.c
	$(CC) $(CFLAGS) -I$(INCLUDE) -c -o parse_tree.o parse_tree.c

generate_code.o: generate_code.c
	$(CC) $(CFLAGS) -I$(INCLUDE) -c -o generate_code.o generate_code.c

list: list/src/list.c
	cd list; $(MAKE)

clean:
	rm -f scanner.c scanner.o parser.c parser.o parser.h parse_tree.o npltohtml \
generate_code.o; cd list; $(MAKE) clean
