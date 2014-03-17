#include "parse_tree.h"

#include <string.h>

text_field_t *text_field_new(void) {
    text_field_t *field = malloc(sizeof(text_field_t));
    field->chunks = list_new();
    return field;
}

text_chunk_t *text_chunk_new(void) {
    return calloc(1, sizeof(text_chunk_t));
}

newspaper_t *newspaper_new(void) {
    return calloc(1, sizeof(newspaper_t));
}

news_t *news_new(void) {
    return calloc(1, sizeof(news_t));
}

structure_t *structure_new(void) {
    return calloc(1, sizeof(structure_t));
}

text_chunk_t *text_chunk_new_copy_attrs(text_chunk_t *copy) {
    text_chunk_t *new_chunk = text_chunk_new();

    if (copy) {
        memcpy(new_chunk, copy, sizeof(text_chunk_t));
        new_chunk->_pos = 0;
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
