#include "generate_code.h"

FILE *html_new(char *page_title) {
    FILE *P = fopen(HTML_FILE_NAME, "w");
    fprintf(P, "%s\n%s%s%s%s%s%s\n%s\n",
            HTML, HEAD, META, TITLE, page_title, TITLE_C, HEAD_C, BODY);

    return P;
}

void html_header(FILE *P, char *page_header) {
    fprintf(P, "%s%s%s\n", H1, page_header, H1_C);
}


void html_close(FILE *P) {
    fprintf(P, "%s%s\n", BODY_C, HTML_C);
    fclose(P);
}
