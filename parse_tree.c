#include "parse_tree.h"

#include <string.h>

typedef void (free_func_t)(void *);

text_field_t *text_field_new(void) {
    text_field_t *field = malloc(sizeof(text_field_t));
    field->chunks = list_new();
    field->chunks->free = (free_func_t *) text_chunk_free;
    return field;
}

void text_field_free(text_field_t *text) {
    list_destroy(text->chunks);
    free(text);
}

text_chunk_t *text_chunk_new(void) {
    return calloc(1, sizeof(text_chunk_t));
}

void text_chunk_free(text_chunk_t *text) {
    free(text->link);
    free(text->alt_text);
    free(text->image);
    free(text->caption);
    free(text);
}

newspaper_t *newspaper_new(void) {
    return calloc(1, sizeof(newspaper_t));
}

void newspaper_free(newspaper_t *newspaper) {
    text_field_free(newspaper->title);
    free(newspaper->date);
    structure_free(newspaper->structure);
    list_destroy(newspaper->news);
    free(newspaper);
}

news_t *news_new(void) {
    return calloc(1, sizeof(news_t));
}

void news_free(news_t *news) {
    text_field_free(news->title);
    text_field_free(news->abstract);
    structure_free(news->structure);
    free(news->author);
    free(news->name);
    if (news->text) text_field_free(news->text);
    if (news->image) free(news->image);
    if (news->source) free(news->source);
    if (news->date) free(news->date);
    free(news);
}

structure_t *structure_new(void) {
    return calloc(1, sizeof(structure_t));
}

void structure_free(structure_t *structure) {
    list_destroy(structure->show);
    free(structure);
}

text_chunk_t *text_chunk_new_copy_attrs(text_chunk_t *copy) {
    text_chunk_t *new_chunk = text_chunk_new();

    if (copy) {
        memcpy(new_chunk, copy, sizeof(text_chunk_t));
        new_chunk->_pos = 0;
        new_chunk->link = new_chunk->alt_text = NULL;
        new_chunk->image = new_chunk->caption = NULL;
        memset(new_chunk->chunk, '\0', TEXT_CHUNK_SIZE);
    }

    return new_chunk;
}

text_chunk_t *text_field_get_last_chunk(text_field_t *field) {
    list_node_t *last_node = list_at(field->chunks, -1);
    if (last_node) {
        return last_node->val;
    }

    return NULL;
}

void text_field_append_char(text_field_t *field, char c) {
    text_chunk_t *last_chunk = text_field_get_last_chunk(field);

    if (!last_chunk || last_chunk->_pos == TEXT_CHUNK_SIZE) {
        // need to create a new empty chunk with the same
        // attributes as the last
        text_chunk_t *new_chunk = text_chunk_new_copy_attrs(last_chunk);
        list_rpush(field->chunks, list_node_new(new_chunk));
        last_chunk = new_chunk;
    }

    last_chunk->chunk[last_chunk->_pos++] = c;
}

void text_field_append_str(text_field_t *field, char *c) {
    while (*c) {
        text_field_append_char(field, *c);
        c++;
    }
}

/* Get the text chunk from field at position */
text_chunk_t *text_field_get_chunk_at(text_field_t *field, int position) {
    if(field) {
        return (text_chunk_t *)list_at(field->chunks, position)->val;
    }
    else {
        return NULL;
    }
}

/* Get the number of columns of a structure */
unsigned int structure_get_col(structure_t *structure) {
    if(structure) {
        return structure->col;
    }
    else {
        return 0;
    }
}

/* Get the order of the objects to be shown */
char *structure_get_show(structure_t *structure, int position) {
    if(structure) {
        return (char *)list_at(structure->show, position)->val;
    }
    else {
        return NULL;
    }
}

news_t *newspaper_find_news(newspaper_t *newspaper, const char *name) {
    list_node_t *n = NULL;
    list_iterator_t *it = list_iterator_new(newspaper->news, LIST_HEAD);
    while ((n = list_iterator_next(it))) {
        news_t *news = n->val;
        if (!strcmp(news->name, name)) {
            return news;
        }
    }

    list_iterator_destroy(it);
    return NULL;
}
