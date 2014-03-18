/* parse_tree.h */
#ifndef __PARSE_TREE_H__
#define __PARSE_TREE_H__

#include <stdbool.h>

#include "list.h"

#define TEXT_CHUNK_SIZE 1024

typedef struct {
    bool bold;
    bool italics;
    bool paragraph;
    unsigned int indentation;
    unsigned int bullet_level;
    unsigned int enumeration_level;
    unsigned int item_counter;

    char *link;
    char *alt_text;

    char *image;
    char *caption;

    char chunk[TEXT_CHUNK_SIZE];
    unsigned int _pos;
} text_chunk_t;

typedef struct {
    list_t *chunks;
} text_field_t;

typedef struct {
    unsigned int col;
    list_t *show; // list of char *
} structure_t;

typedef struct {
    text_field_t *title;
    char *date;
    structure_t *structure;
    list_t *news;
} newspaper_t;

typedef struct {
    char *name;
    text_field_t *title;
    char *image;
    text_field_t *abstract;
    text_field_t *text;
    char *author;
    char *source;
    char *date;
    structure_t *structure;
} news_t;

newspaper_t *newspaper_new(void);
void newspaper_free(newspaper_t *newspaper);
news_t *news_new(void);
void news_free(news_t *news);
structure_t *structure_new(void);
void structure_free(structure_t *structure);
text_field_t *text_field_new(void);
void text_field_free(text_field_t *text);
text_chunk_t *text_chunk_new(void);
void text_chunk_free(text_chunk_t *text);
text_chunk_t *text_chunk_new_copy_attrs(text_chunk_t *copy);
text_chunk_t *text_field_get_last_chunk(text_field_t *field);
void text_field_append_char(text_field_t *field, char c);
void text_field_append_str(text_field_t *field, char *c);
text_chunk_t *text_field_get_chunk_at(text_field_t *field, int position);
unsigned int structure_get_col(structure_t *structure);
char *structure_get_show(structure_t *structure, int position);
news_t *newspaper_find_news(newspaper_t *newspaper, const char *name);

#endif /* __PARSE_TREE_H__ */
