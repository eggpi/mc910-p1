/* generate_code.h */
#ifndef __GENERATE_CODE_H__
#define __GENERATE_CODE_H__

#include <stdio.h>
#include "parse_tree.h"

#define HTML_FILE_NAME "sempre_online.html"

#define HTML "<!DOCTYPE html>\n<html lang=\"pt-br\">"
#define HTML_C "</html>"
#define HEAD "<head>"
#define HEAD_C "</head>"
#define META "<meta http-equiv=\"Content-Type\" \
content=\"text/html; charset=UTF-8\" />"
#define TITLE "<title>"
#define TITLE_C "</title>"
#define LINK "<link rel=\"stylesheet\" type=\"text/css\" \
href=\"style/style.css\" media=\"screen\" />"
#define SCRIPT "<script type=\"text/javascript\""
#define SCRIPT_C "</script>"
#define BODY "<body>"
#define BODY_C "</body>"
#define H1 "<h1>"
#define H1_C "</h1>"
#define H2 "<h2>"
#define H2_C "</h2>"
#define H3 "<h3>"
#define H3_C "</h3>"
#define DIV "<div"
#define DIV_C "</div>"
#define P "<p>"
#define P_C "</p>"
#define BR "<br>"
#define TABLE "<table"
#define TABLE_C "</table>"
#define TR "<tr>"
#define TR_C "</tr>"
#define TD "<td"
#define TD_C "</td>"
#define IMGSRC "<img src=\"img/"
#define TAG_C ">"
#define IMG_C "</img>"
#define B "<b>"
#define B_C "</b>"
#define I "<i>"
#define I_C "</i>"
#define AHREF "<a href=\""
#define AHREF_C "\" target=\"_blank\">"
#define A_C "</a>"
#define SPAN "<span"
#define SPAN_C "</span>"
#define UL "<ul>"
#define LI "<li>"
#define LI_C "</li>"
#define UL_C "</ul>"
#define OL "<ol>"
#define OL_C "</ol>"

#define PARAGRAPH_INDENTATION "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"


void html_generate(newspaper_t *newspaper);
FILE *html_new(char *page_title);
void html_header(FILE *PG, char *page_header);
void html_news(FILE *PG, newspaper_t *newspaper);
void html_close(FILE *PG);

#endif /* __GENERATE_CODE_H__ */
