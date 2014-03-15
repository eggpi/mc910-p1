#include "parse_tree.h"

#include <string.h>

void text_field_append_char(text_field_t *field, char c) {
    text_chunk_t *last_chunk = NULL;
    list_node_t *last_node = list_at(field->chunks, -1);
    if (last_node) {
        last_chunk = last_node->val;
    }

    if (!last_chunk || last_chunk->_pos == TEXT_CHUNK_SIZE) {
        // need to create a new empty chunk with the same
        // attributes as the last
        text_chunk_t *new_chunk = calloc(1, sizeof(text_chunk_t));

        if (last_chunk) {
            memcpy(new_chunk, last_chunk, sizeof(text_chunk_t));
            new_chunk->_pos = 0;
            memset(new_chunk->chunk, '\0', TEXT_CHUNK_SIZE);
        }

        list_rpush(field->chunks, list_node_new(new_chunk));
        last_chunk = new_chunk;
    }

    last_chunk->chunk[last_chunk->_pos++] = c;
}
