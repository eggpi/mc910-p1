/* generate_code.h */
#ifndef __GENERATE_CODE_H__
#define __GENERATE_CODE_H__

#include <stdio.h>
#include "parse_tree.h"

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
#define P "<p>"
#define P_C "</p>"
#define TABLE "<table>"
#define TABLE_C "</table>"
#define TR "<tr>"
#define TR_C "</tr>"
#define TD "<td>"
#define TD_C "</td>"


void html_generate(newspaper_t *newspaper);
FILE *html_new(char *page_title);
void html_header(FILE *PG, char *page_header);
void html_close(FILE *PG);

#endif /* __GENERATE_CODE_H__ */
