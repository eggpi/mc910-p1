#include "generate_code.h"
#include <string.h>

static void emit_markup_text(FILE *PG, text_field_t *text, bool paragraph);
static void emit_news(FILE *PG, news_t *news);

/* WIP */
void html_generate(newspaper_t *newspaper) {
    FILE *PG = NULL;

    PG = html_new(text_field_get_chunk_at(newspaper->title, 0)->chunk);
    html_header(PG, text_field_get_chunk_at(newspaper->title, 0)->chunk);
    html_news(PG, newspaper);

    html_close(PG);

}

/* Create a new HTML file with some basic tags */
FILE *html_new(char *page_title) {
    FILE *PG = fopen(HTML_FILE_NAME, "w");
    fprintf(PG, "%s\n%s\n%s\n%s%s%s\n%s\n%s\n%s\n",
            HTML, HEAD, META, TITLE, page_title, TITLE_C, LINK, HEAD_C, BODY);

    return PG;
}

/* Print a page header using h1 tag */
void html_header(FILE *PG, char *page_header) {
    fprintf(PG, "%s%s%s\n", H1, page_header, H1_C);
}

/* Print the news */
void html_news(FILE *PG, newspaper_t *newspaper) {
    unsigned int newspaper_col = structure_get_col(newspaper->structure);
    unsigned int remaining_col = newspaper_col;
    unsigned int news_col;
    list_node_t *node = NULL;
    list_iterator_t *it = NULL;

    fprintf(PG, "%s cellspacing=\"0\" cellpadding=\"8\" width=\"1024\" \
            border=\"0\"%s\n%s\n", TABLE, TAG_C, TR);
    it = list_iterator_new(newspaper->structure->show, LIST_HEAD);
    while((node = list_iterator_next(it))) {
        const char *name = node->val;
        news_t *news = newspaper_find_news(newspaper, name);
        if (!news) {
            fprintf(stderr, "referenced news %s doesn't exist!\n", name);
            return;
        }

        news_col = structure_get_col(news->structure);
        if(remaining_col == 0) {
            fprintf(PG, "%s\n%s\n", TR_C, TR);
            remaining_col = newspaper_col;
        }

        fprintf(PG, "%s width=\"%d%%\" colspan=\"%d\" align=\"justify\" \
                valign=\"top\"%s\n",
                TD, (int)(news_col * 100 / newspaper_col), news_col, TAG_C);
        emit_news(PG, news);
        fprintf(PG, "%s\n", TD_C);

        remaining_col -= news_col;
    }

    fprintf(PG, "%s\n%s\n", TR_C, TABLE_C);
    list_iterator_destroy(it);
}

void emit_news(FILE *PG, news_t *news) {
    fprintf(PG, "%s", H2);
    emit_news_title(PG, news);
    fprintf(PG, "%s\n", H2_C);

    if (news->image) {
        fprintf(PG, "%s id=\"figura\"%s%s%s%s\" class=\"escala\"%s%s%s%s\n",
                DIV, TAG_C, P, IMGSRC, news->image, TAG_C, IMG_C, P_C, DIV_C);
    }

    emit_markup_text(PG, news->abstract, true);
    fprintf(PG, "%s%s%sAutor:%s %s%s%s\n",
            BR, P, B, B_C, news->author, P_C, BR);
}

#define GEN_NEED_OPEN_ATTRIBUTE(attr)                                   \
    bool need_open_##attr(text_chunk_t *previous, text_chunk_t *next) { \
        if (previous) {                                                 \
            return previous->attr == false && next->attr == true;       \
        }                                                               \
                                                                        \
        return next->attr;                                              \
    }                                                                   \

#define GEN_NEED_CLOSE_ATTRIBUTE(attr)                                   \
    bool need_close_##attr(text_chunk_t *previous, text_chunk_t *next) { \
        if (previous) {                                                  \
            return previous->attr == true && next->attr == false;        \
        }                                                                \
                                                                         \
        return false;                                                    \
    }                                                                    \

GEN_NEED_OPEN_ATTRIBUTE(bold)
GEN_NEED_CLOSE_ATTRIBUTE(bold)

GEN_NEED_OPEN_ATTRIBUTE(italics)
GEN_NEED_CLOSE_ATTRIBUTE(italics)

GEN_NEED_OPEN_ATTRIBUTE(paragraph)
GEN_NEED_CLOSE_ATTRIBUTE(paragraph)

bool need_indentation(text_chunk_t *previous, text_chunk_t *next) {
    if (previous) {
        return previous->indentation != next->indentation;
    }

    return !!next->indentation;
}

#define GEN_COMPUTE_LEVEL_VARIATION(type)                                        \
    int compute_##type##_variation(text_chunk_t *previous, text_chunk_t *next) { \
        if (previous) {                                                          \
            return next->type##_level - previous->type##_level;                  \
        }                                                                        \
                                                                                 \
        return next->type##_level;                                               \
    }

GEN_COMPUTE_LEVEL_VARIATION(bullet)
GEN_COMPUTE_LEVEL_VARIATION(enumeration)

bool need_open_list_item(text_chunk_t *previous, text_chunk_t *next) {
    if (next->bullet_level == 0 && next->enumeration_level == 0) {
        return false;
    }

    if (previous) {
        return previous->item_counter != next->item_counter;
    }

    return true;
}

void emit_news_title(FILE *PG, news_t *news) {
    if(news->text) {
        fprintf(PG, "%sjavascript:void(0)\"", AHREF);
    }
    emit_markup_text(PG, news->title, false);
    if(news->text) {
        fprintf(PG, "%s\n", A_C);
    }
}

void emit_markup_text(FILE *PG, text_field_t *text, bool paragraph) {
    list_node_t *n = NULL;
    text_chunk_t *previous = NULL;

    // create a sentinel chunk with no attributes
    // to make sure all tags are closed
    list_rpush(text->chunks, list_node_new(text_chunk_new()));

    list_iterator_t *it = list_iterator_new(text->chunks, LIST_HEAD);

    if(paragraph) {
        fprintf(PG, "%s\n", P);
    }
    while ((n = list_iterator_next(it))) {
        text_chunk_t *chunk = n->val;

        if (need_close_bold(previous, chunk)) fprintf(PG, "%s", B_C);
        if (need_close_italics(previous, chunk)) fprintf(PG, "%s", I_C);
        if (need_close_paragraph(previous, chunk)) fprintf(PG, "%s", H3_C);

        // adjust the level for bullet lists or enumeration lists
        int bullet_diff = compute_bullet_variation(previous, chunk);
        if (bullet_diff > 0) {
            while (bullet_diff--) fprintf(PG, "%s\n", UL);
        } else if (bullet_diff < 0) {
            fprintf(PG, "%s\n", LI_C);
            while (bullet_diff++) {
                fprintf(PG, "%s\n", UL_C);
            }
        }

        int enumeration_diff = compute_enumeration_variation(previous, chunk);
        if (enumeration_diff > 0) {
            while (enumeration_diff--) fprintf(PG, "%s\n", OL);
        } else if (enumeration_diff < 0) {
            fprintf(PG, "%s\n", LI_C);
            while (enumeration_diff++) {
                fprintf(PG, "%s\n", OL_C);
            }
        }

        if (need_open_list_item(previous, chunk)) {
            fprintf(PG, "%s\n", LI);
        }

        if (need_open_bold(previous, chunk)) fprintf(PG, "%s", B);
        if (need_open_italics(previous, chunk)) fprintf(PG, "%s", I);
        if (need_open_paragraph(previous, chunk)) fprintf(PG, "%s", H3);

        if (need_indentation(previous, chunk)) {
            if (previous != NULL) fprintf(PG, "%s\n", P_C);
            fprintf(PG, "%s\n", P);

            unsigned int indentation = chunk->indentation;
            while (indentation--) fprintf(PG, PARAGRAPH_INDENTATION);
        }

        // text and image links create their own chunks, so emit them before
        // the actual text
        if (chunk->link && chunk->alt_text) {
            fprintf(PG, "%s%s%s%s%s", AHREF, chunk->link, AHREF_C,
                    chunk->alt_text, A_C);
        } else if (chunk->image && chunk->caption) {
            fprintf(PG, "%s%s\" %s\"%s\"%s%s", IMGSRC, chunk->image, ALT,
                    chunk->caption, TAG_C, IMG_C);
        }

        fprintf(PG, "%s", chunk->chunk);

        previous = chunk;
    }

    if(paragraph) {
        fprintf(PG, "%s\n", P_C);
    }

    list_remove(text->chunks, text->chunks->tail);
    list_iterator_destroy(it);
    return;
}

/* Close the HTML file */
void html_close(FILE *PG) {
    fprintf(PG, "%s%s\n", BODY_C, HTML_C);
    fclose(PG);
}
