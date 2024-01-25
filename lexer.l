%{
    #include <string.h>
    #include "parser.hpp"
%}

%option noyywrap
%option yylineno

%%

ALT {
    return alt;
}

ALTGR {
    return altgr;
}

APP|MENU {
    return menu;
}

BACKSPACE {
    return backspace;
}

BREAK|PAUSE {
    return pause_key;
}

CAPSLOCK {
    return capslock;
}

CONTROL|CTRL {
    return ctrl;
}

DEFAULT_DELAY\ [0-9]+ {
    yylval.integer = atoi(&yytext[14]);
    return default_delay;
}

DEFAULTDELAY\ [0-9]+ {
    yylval.integer = atoi(&yytext[13]);
    return default_delay;
}

DELAY\ [0-9]+ {
    yylval.integer = atoi(&yytext[6]);
    return delay_key;
}

DELETE {
    return delete_key;
}

DOWN|DOWNARROW {
    return down;
}

END {
    return end;
}

ENTER {
    return enter;
}

ESC|ESCAPE {
    return esc;
}

F[0-9]+ {
    yylval.integer = atoi(&yytext[1]);
    return function;
}

GUI|WINDOWS {
    return gui;
}

HOME {
    return home;
}

INSERT {
    return insert;
}   

LEFT|LEFTARROW {
    return left;
}

NUMLOCK {
    return numlock;
}

PAGEDOWN {
    return pagedown;
}

PAGEUP {
    return pageup;
}

PRINTSCREEN {
    return printscreen;
}

REM\ [[:graph:]|[:blank:]]* {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[4]);
    return rem;
}

REPEAT\ [0-9]+ {
    yylval.integer = atoi(&yytext[7]);
    return repeat;
}

RIGHT|RIGHTARROW {
    return right;
}

SCROLLLOCK {
    return scrolllock;
}

SHIFT {
    return shift;
}

SPACE {
    return space;
}

STRING\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[7]);
    return string;
}

TAB {
    return tab;
}

UP|UPARROW {
    return up;
}

\n|(\r\n) {
    return new_line;
}

[[:blank:]]+ {
    return separator;
}

[[:alpha:]] {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, yytext);
    return letter;
}
%%
