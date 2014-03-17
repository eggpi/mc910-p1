#include "generate_code.h"

/* WIP */
void html_generate(newspaper_t *newspaper) {
    FILE *PG = NULL;
    PG = html_new(text_field_get_chunk_at(newspaper->title, 0)->chunk);
    html_header(PG, text_field_get_chunk_at(newspaper->title, 0)->chunk);

    html_close(PG);

}

FILE *html_new(char *page_title) {
    FILE *PG = fopen(HTML_FILE_NAME, "w");
    fprintf(PG, "%s\n%s%s%s%s%s%s\n%s\n",
            HTML, HEAD, META, TITLE, page_title, TITLE_C, HEAD_C, BODY);

    return PG;
}

void html_header(FILE *PG, char *page_header) {
    fprintf(PG, "%s%s%s\n", H1, page_header, H1_C);
}


void html_close(FILE *PG) {
    fprintf(PG, "%s%s\n", BODY_C, HTML_C);
    fclose(PG);
}
