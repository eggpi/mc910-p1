#include "generate_code.h"
#include <string.h>

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
    fprintf(PG, "%s\n%s%s%s%s%s%s\n%s\n",
            HTML, HEAD, META, TITLE, page_title, TITLE_C, HEAD_C, BODY);

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
    list_node_t *node_news = NULL;
    list_iterator_t *it = NULL, *it2 = NULL;


    fprintf(PG, "%s\n%s\n", TABLE, TR);
    it = list_iterator_new(newspaper->structure->show, LIST_HEAD);
    while((node = list_iterator_next(it))) {
        it2 = list_iterator_new(newspaper->news, LIST_HEAD);
        while((node_news = list_iterator_next(it2))) {
            if(!strcmp(node->val, ((news_t *)node_news->val)->name)) {
                news_col =
                    structure_get_col(((news_t *)node_news->val)->structure);
                if(remaining_col == 0) {
                    fprintf(PG, "%s\n%s\n", TR_C, TR);
                    remaining_col = newspaper_col;
                }
                fprintf(PG, "%s colspan=%d align=center>%s%s\n", TD, news_col,
                        (char *)node->val, TD_C);

                remaining_col -= news_col;
            }
        }
    }
    fprintf(PG, "%s\n%s\n", TR_C, TABLE_C);
    list_iterator_destroy(it);
    list_iterator_destroy(it2);
}

/* Close the HTML file */
void html_close(FILE *PG) {
    fprintf(PG, "%s%s\n", BODY_C, HTML_C);
    fclose(PG);
}
