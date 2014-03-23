%{
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>

#include "parse_tree.h"
#include "generate_code.h"

int yyerror(const char* errmsg);
int yylex(void);

char *string_to_lower(char *str);
void adjust_indices(char **begin, char **end);
void parse_text_link(text_chunk_t *chunk, const char *link);
void parse_image_link(text_chunk_t *chunk, const char *link);
char *text_field_to_string(text_field_t *field);
bool validate_newspaper(newspaper_t *newspaper);

static newspaper_t *newspaper;
%}

%union{
    char *str;
    unsigned long num;
    list_t *list;

    newspaper_t *newspaper;
    structure_t *structure;
    news_t *news;
    text_field_t *text;
}

%token <str> T_TEXT
%token T_NEWSPAPER
%token <str> T_TITLE
%token <str> T_DATE
%token <str> T_ABSTRACT
%token <str> T_SOURCE
%token <str> T_IMAGE
%token <str> T_AUTHOR
%token <str> T_STRUCTURE
%token T_COL
%token T_SHOW
%token <str> T_NEWSNAME
%token T_BOLD;
%token T_ITALICIZED;
%token T_TITLE_PARAGRAPH;
%token <str> T_TEXT_LINK;
%token <str> T_IMAGE_LINK;
%token <num> T_PARAGRAPH;
%token <num> T_BULLET;
%token <num> T_ENUMERATION;
%token <num> T_NUM
%token <str> T_QUOTED_STR

%type <num> col_stmt
%type <news> news_stmt news_attrs_stmt
%type <structure> structure_stmt news_structure_stmt
%type <list> show_stmt news_show_stmt news_name_list news_attr_list news_list
%type <text> title_stmt abstract_stmt text_stmt quoted_string quoted_string_markup literal_string_markup
%type <str> image_stmt date_stmt source_stmt author_stmt literal_string

%start newspaper_stmt

%error-verbose

%%

newspaper_stmt: T_NEWSPAPER '{'
    title_stmt
    date_stmt
    structure_stmt
    news_list
'}' {
    newspaper = newspaper_new();
    newspaper->title = $3;
    newspaper->date = $4;
    newspaper->structure = $5;
    newspaper->news = $6;
}
;

literal_string_markup: '"' quoted_string_markup '"' {
    $$ = $2;
}
;

literal_string: '"' quoted_string '"' {
    $$ = text_field_to_string($2);
}
;

quoted_string:
    T_QUOTED_STR {
        $$ = text_field_new();
        text_field_append_str($$, $1);
    }
    | quoted_string T_QUOTED_STR {
        text_field_append_str($$, $2);
    }
;

quoted_string_markup:
    T_QUOTED_STR {
        $$ = text_field_new();
        text_field_append_str($$, $1);
    }
    | quoted_string_markup T_QUOTED_STR {
        text_field_append_str($$, $2);
    }
    | T_BOLD {
        $$ = text_field_new();
        text_chunk_t *chunk = text_chunk_new();

        chunk->bold = true;
        list_rpush($$->chunks, list_node_new(chunk));
    }
    | quoted_string_markup T_BOLD {
        text_chunk_t *last_chunk = text_field_get_last_chunk($$);
        text_chunk_t *new = text_chunk_new_copy_attrs(last_chunk);

        new->bold = !last_chunk->bold;
        list_rpush($$->chunks, list_node_new(new));
    }
    | T_ITALICIZED {
        $$ = text_field_new();
        text_chunk_t *chunk = text_chunk_new();

        chunk->italics = true;
        list_rpush($$->chunks, list_node_new(chunk));
    }
    | quoted_string_markup T_ITALICIZED {
        text_chunk_t *last_chunk = text_field_get_last_chunk($$);
        text_chunk_t *new = text_chunk_new_copy_attrs(last_chunk);

        new->italics = !last_chunk->italics;
        list_rpush($$->chunks, list_node_new(new));
    }
    | T_TITLE_PARAGRAPH {
        $$ = text_field_new();
        text_chunk_t *chunk = text_chunk_new();

        chunk->paragraph = true;
        list_rpush($$->chunks, list_node_new(chunk));
    }
    | quoted_string_markup T_TITLE_PARAGRAPH {
        text_chunk_t *last_chunk = text_field_get_last_chunk($$);
        text_chunk_t *new = text_chunk_new_copy_attrs(last_chunk);

        new->paragraph = !last_chunk->paragraph;
        list_rpush($$->chunks, list_node_new(new));
    }
    | T_TEXT_LINK {
        $$ = text_field_new();
        text_chunk_t *chunk = text_chunk_new();

        parse_text_link(chunk, $1);
        list_rpush($$->chunks, list_node_new(chunk));
    }
    | quoted_string_markup T_TEXT_LINK {
        text_chunk_t *last_chunk = text_field_get_last_chunk($$);
        text_chunk_t *new = text_chunk_new_copy_attrs(last_chunk);

        parse_text_link(new, $2);
        list_rpush($$->chunks, list_node_new(new));
    }
    | quoted_string_markup T_IMAGE_LINK {
        text_chunk_t *last_chunk = text_field_get_last_chunk($$);
        text_chunk_t *new = text_chunk_new_copy_attrs(last_chunk);

        parse_image_link(new, $2);
        list_rpush($$->chunks, list_node_new(new));
    }
    | quoted_string_markup T_PARAGRAPH {
        text_chunk_t *last_chunk = text_field_get_last_chunk($$);
        text_chunk_t *new = text_chunk_new_copy_attrs(last_chunk);

        new->indentation = $2;
        new->bullet_level = new->enumeration_level = 0;
        list_rpush($$->chunks, list_node_new(new));
    }
    | quoted_string_markup T_BULLET {
        text_chunk_t *last_chunk = text_field_get_last_chunk($$);
        text_chunk_t *new = text_chunk_new_copy_attrs(last_chunk);

        new->bullet_level = $2;
        new->enumeration_level = 0;
        list_rpush($$->chunks, list_node_new(new));
    }
    | quoted_string_markup T_ENUMERATION {
        text_chunk_t *last_chunk = text_field_get_last_chunk($$);
        text_chunk_t *new = text_chunk_new_copy_attrs(last_chunk);

        new->enumeration_level = $2;
        new->bullet_level = 0;
        list_rpush($$->chunks, list_node_new(new));
    }
;

title_stmt: T_TITLE '=' literal_string_markup {
    $$ = $3;
}
;

date_stmt: T_DATE '=' literal_string {
    $$ = $3;
}
;

structure_stmt: T_STRUCTURE '{'
    col_stmt
    show_stmt
'}' {
    $$ = structure_new();
    $$->col = $3;
    $$->show = $4;
}
;

col_stmt: T_COL '=' T_NUM {
    $$ = yylval.num;
}
;

show_stmt: T_SHOW '=' news_name_list {
    $$ = $3;
    $$->free = free;
}
;

news_name_list: T_NEWSNAME {
        $$ = list_new();
        list_rpush($$, list_node_new(string_to_lower($1)));
    }
    | news_name_list ',' T_NEWSNAME {
        list_rpush($$, list_node_new(string_to_lower($3)));
    }
;

news_stmt: T_NEWSNAME '{'
    news_attrs_stmt
    news_structure_stmt
'}' {
    $$ = $3;
    $$->name = string_to_lower($1);
    $$->structure = $4;
    // the other attributes were filled out by news_attrs_stmt
}
;

news_list: news_stmt {
        $$ = list_new();
        $$->free = (void (*) (void *)) news_free;
        list_rpush($$, list_node_new($1));
    }
    | news_list news_stmt {
        list_rpush($$, list_node_new($2));
    }
;

news_attrs_stmt:
    title_stmt { $$ = news_new(); $$->title = $1; }
    | news_attrs_stmt title_stmt { $$->title = $2; }
    | abstract_stmt { $$ = news_new(); $$->abstract = $1; }
    | news_attrs_stmt abstract_stmt { $$->abstract = $2; }
    | author_stmt { $$ = news_new(); $$->author = $1; }
    | news_attrs_stmt author_stmt { $$->author = $2; }
    | date_stmt { $$ = news_new(); $$->date = $1; }
    | news_attrs_stmt date_stmt { $$->date = $2; }
    | image_stmt { $$ = news_new(); $$->image = $1; }
    | news_attrs_stmt image_stmt { $$->image = $2; }
    | text_stmt { $$ = news_new(); $$->text = $1; }
    | news_attrs_stmt text_stmt { $$->text = $2; }
    | source_stmt { $$ = news_new(); $$->source = $1; }
    | news_attrs_stmt source_stmt { $$->source = $2; }
;

abstract_stmt: T_ABSTRACT '=' literal_string_markup {
    $$ = $3;
}
;

author_stmt: T_AUTHOR '=' literal_string {
    $$ = $3;
}
;

image_stmt: T_IMAGE '=' literal_string {
    $$ = $3;
}
;

text_stmt: T_TEXT '=' literal_string_markup {
    $$ = $3;
}
;

source_stmt: T_SOURCE '=' literal_string {
    $$ = $3;
}
;

news_structure_stmt: T_STRUCTURE '{'
    col_stmt
    news_show_stmt
'}' {
    $$ = structure_new();
    $$->col = $3;
    $$->show = $4;
}

news_show_stmt: T_SHOW '=' news_attr_list {
    $$ = $3;
    $$->free = free;
}
;

news_attr_list:
    T_TITLE { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_TITLE { list_rpush($$, list_node_new($3)); }
    | T_ABSTRACT { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_ABSTRACT { list_rpush($$, list_node_new($3)); }
    | T_AUTHOR { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_AUTHOR { list_rpush($$, list_node_new($3)); }
    | T_DATE { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_DATE { list_rpush($$, list_node_new($3)); }
    | T_IMAGE { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_IMAGE { list_rpush($$, list_node_new($3)); }
    | T_TEXT { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_TEXT { list_rpush($$, list_node_new($3)); }
    | T_SOURCE { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_SOURCE { list_rpush($$, list_node_new($3)); }
;

%%

/* Convert a string to lowercase */
char *string_to_lower(char *str) {
    int i;
    for(i = 0; str[i]; i++) {
        str[i] = tolower(str[i]);
    }

    return str;
}

/* Adjust indices to create correct links and caption despite blank spaces */
void adjust_indices(char **begin, char **end) {
    while(isspace(**begin)) {
        (*begin)++;
    }
    while(isspace(**end)) {
        (*end)--;
    }
    (*end)++;
}

void parse_text_link(text_chunk_t *chunk, const char *link) {
    // link has the form [ url | text ]; parse it
    char *sep = strchr(link, '|');
    char *url_end = sep - 1;
    char *text_end = NULL;
    if (sep == NULL) {
        chunk->link = strndup(link + 1, strlen(link) - 2);
        chunk->alt_text = strdup(chunk->link);
    } else {
        link += 1; // skip "["
        adjust_indices((char **)&link, &url_end);
        chunk->link = strndup(link, url_end - link);

        sep +=1; // skip "|"
        text_end = (char *)link + strlen(link) - 2;
        adjust_indices(&sep, &text_end);
        chunk->alt_text = strndup(sep, text_end - sep);
    }

    return;
}

void parse_image_link(text_chunk_t *chunk, const char *link) {
    // link has the form [[ image | caption ]]; parse it
    char *sep = strchr(link, '|');
    char *image_end = sep - 1;
    char *caption_end = NULL;
    link += 2; // skip "[["
    adjust_indices((char **)&link, &image_end);
    chunk->image = strndup(link, image_end - link);

    sep += 1; // skip "|"
    caption_end = (char *)link + strlen(link) - 3;
    adjust_indices(&sep, &caption_end);
    chunk->caption = strndup(sep, caption_end - sep);

    return;
}

char *text_field_to_string(text_field_t *field) {
    unsigned int len = TEXT_CHUNK_SIZE * (field->chunks->len - 1);
    len += text_field_get_last_chunk(field)->_pos;

    char *text = malloc(len + 1), *start = text;
    list_node_t *node = NULL;
    list_iterator_t *it = list_iterator_new(field->chunks, LIST_HEAD);
    while ((node = list_iterator_next(it))) {
        text_chunk_t *chunk = node->val;

        strcat(start, chunk->chunk);
        start += chunk->_pos;
    }

    list_iterator_destroy(it);
    return text;
}

bool verify_newspaper(newspaper_t *newspaper) {
    // The grammar doesn't check for the presence of all
    // mandatory attributes in each news entry, so do it here.

    int index = 0;
    list_node_t *node = NULL;
    list_iterator_t *it = list_iterator_new(newspaper->news, LIST_HEAD);
    while ((node = list_iterator_next(it))) {
        news_t *news = node->val;
        // news->structure is enforced by the grammar
        if (!news->title || !news->abstract || !news->author) {
            char *errmsg = NULL;
            asprintf(&errmsg,
                "%d-th news is missing a mandatory attribute.",
                index);

            yyerror(errmsg);
            free(errmsg);
            return false;
        }

        index++;
    }

    list_iterator_destroy(it);
    return true;
}

int yyerror(const char* errmsg)
{
    fprintf(stderr, "\nError: %s\n", errmsg);
    return 0;
}

int yywrap(void) {
    return 1;
}

int main(void)
{
    yyparse();

    /* Test newspaper for correctness */
    if (!newspaper || (!verify_newspaper(newspaper))) {
        return 1;
    }
 
    /* Generate the HTML newspaper */
    html_generate(newspaper);
    newspaper_free(newspaper);

    return 0;
}
