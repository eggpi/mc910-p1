#include <stdio.h>

#define HTML_FILE_NAME "sempre_online.html"

#define HTML "<html>"
#define HTML_C "</html>"
#define HEAD "<head>"
#define HEAD_C "</head>"
#define META "<meta http-equiv=\"Content-Type\" \
content=\"text/html; charset=UTF-8\">"
#define TITLE "<title>"
#define TITLE_C "</title>"
#define BODY "<body>"
#define BODY_C "</body>"
#define H1 "<h1>"
#define H1_C "</h1>"


FILE *html_new(char *page_title);
void html_header(FILE *P, char *page_header);
void html_close(FILE *P);
