%{
/*
 * This file is part of the Capibara zero (https://github.com/CapibaraZero/fw or https://capibarazero.github.io/).
 * Copyright (c) 2020 msommacal
 * Copyright (c) 2024 Andrea Canale.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

    #include <string>
    #include <bits/stdc++.h>
    #include "parser.hpp"
    extern "C" int yylex();

    bool is_number(const char *s) {
	char* p;
	long converted = strtol(s, &p, 10);
	if (*p) {
	    return false;
	}
	else {
	    return true;
	}
    }

    int replacechar(char *str, char orig, char rep) {
	char *ix = str;
	int n = 0;
        while((ix = strchr(ix, orig)) != NULL) {
	    *ix++ = rep;
	    n++;
        }
	return n;
    }
void replace_first(
    std::string& s,
    std::string const& toReplace,
    std::string const& replaceWith
) {
    std::size_t pos = s.find(toReplace);
    if (pos == std::string::npos) return;
    s.replace(pos, toReplace.length(), replaceWith);
}
%}

%option noyywrap
%option yylineno
%x STRING_CONTENT STRINGLN_CONTENT REM_BLOCK_CONTENT

%%

BACKSPACE {
    return backspace;
}

CAPSLOCK {
    return capslock;
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

END {
    return end;
}

NUMLOCK {
    return numlock;
}

REM\ [[:graph:]|[:blank:]]+ { /* Do nothing*/ }	

REM_BLOCK { BEGIN(REM_BLOCK_CONTENT); }

<REM_BLOCK_CONTENT>{
    "END_REM"    { BEGIN(INITIAL);	/* Return to normal state */ }
    [[:graph:][:blank:]]+  { /* Do nothing */ }
}

REPEAT\ [0-9]+ {
    yylval.integer = atoi(&yytext[7]);
    return repeat;
}

SCROLLLOCK {
    return scrolllock;
}

STRING {
    BEGIN(STRING_CONTENT);
}

STRING\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[7]);
    return string;
}

<STRING_CONTENT>{
    "END_STRING"    { BEGIN(INITIAL);	/* Return to normal state */ }
    [[:graph:][:blank:]]+  { 
                        yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
                        strcpy(yylval.text, yytext);	
			return multiline_string;
                    }
}

STRINGLN {
    BEGIN(STRINGLN_CONTENT);
}

STRINGLN\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[9]);
    return stringln;    
}

<STRINGLN_CONTENT>{
    "END_STRINGLN"    { BEGIN(INITIAL);	/* Return to normal state */ }
    [[:graph:][:blank:]]+  { 
                        yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
                        strcpy(yylval.text, yytext);	
			return multiline_stringln;
                    }
}

DELETE {
    return delete_key;
}

DOWN|DOWNARROW {
    return down;
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

PAGEDOWN {
    return pagedown;
}

PAGEUP {
    return pageup;
}

RIGHT|RIGHTARROW {
    return right;
}

SPACE {
    return space;
}

TAB {
    return tab;
}

UP|UPARROW {
    return up;
}

ENTER {
    return enter;
}

ESC|ESCAPE {
    return esc;
}

F[0-12]+ {
    yylval.integer = atoi(&yytext[1]);
    return function;
}

PRINTSCREEN {
    return printscreen;
}

APP|MENU {
    return menu;
}

BREAK|PAUSE {
    return pause_key;
}

ALT {
    return alt;
}

ALTGR {
    return altgr;
}

CONTROL|CTRL {
    return ctrl;
}

GUI|WINDOWS {
    return gui;
}

SHIFT {
    return shift;
}

CTRL\ ALT\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[9]);
    return ctrl_alt;
}

CTRL\ SHIFT\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[11]);
    return ctrl_alt; 
}

ALT\ SHIFT\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[10]);
    return alt_shift;
}


VAR\ [a-zA-Z|$|0-9|=|[:blank:]|[:graph:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[5]);
    std::stringstream iss = std::stringstream(yylval.text);
    std::string s;
    int i = 0;
    while ( getline( iss, s, '=' ) ) {	// Figure out the variable type
	if(i++ == 1) {	// Go to latest index(if we split for =)
	    if(is_number(s.c_str())) {	// Int var found
		return num_var;
	    } else {
		size_t found = strcspn(yylval.text, "=");	// string need to be inside double quotes
		yylval.text[found + 1] = '"';
		return str_var;
	    }
	}
    }
}

DEFINE\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[8]);
    std::stringstream iss = std::stringstream(yylval.text);
    std::string s;
    int i = 0;
    while ( getline( iss, s, ' ' ) ) {	// Figure out the variable type
	if(i++ == 1) {	// Go to latest index(if we split for =)
	    if(is_number(s.c_str())) {	// Int var found
		return num_define;
	    } else {
		size_t found = strcspn(yylval.text, "=");	// string need to be inside double quotes
		yylval.text[found + 1] = '"';
		return str_define;
	    }
	}
    }
 
} 

IF\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[2]);
    replacechar(yylval.text, '$', ' ');
    yylval.text[strlen(yytext) - 6] = '\0'; 
    return if_statement;
}

END_IF {
    return end_if;
}

ATTACKMODE\ [[:graph:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[11]);
    return attackmode;
}


WAIT_FOR_BUTTON_PRESS {
    return wait_for_button_press;
}

DISABLE_BUTTON {
    return disable_button;
}

ENABLE_BUTTON {
    return enable_button;
}

RESTART_PAYLOAD {
    return restart_payload;
}

STOP_PAYLOAD {
    return stop_payload;
}

RESET {
    return reset;
}


$_JITTER_ENABLED\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[18]);
    return jitter_enabled_key;
}

$_JITTER_MAX\ [[:graph:]|[:blank:]]+  {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[15]);
    return jitter_max_key;
}


RANDOM_LOWERCASE_LETTER {
    return random_lowercase_letter_keyword;
}

RANDOM_UPPERCASE_LETTER {
    return random_uppercase_letter_keyword;
}

RANDOM_LETTER {
    return random_letter_keyword;
}

RANDOM_NUMBER {
    return random_number_keyword;
}

RANDOM_SPECIAL {
    return random_special_keyword;
}

RANDOM_CHAR {
    return random_char_keyword;
}

HIDE_PAYLOAD {}

RESTORE_PAYLOAD {}

WAIT_FOR_CAPS_ON {}

WAIT_FOR_CAPS_OFF {}

WAIT_FOR_CAPS_CHANGE {}

WAIT_FOR_NUM_ON {}

WAIT_FOR_NUM_OFF {}

WAIT_FOR_NUM_CHANGE {}

WAIT_FOR_SCROLL_ON {}

WAIT_FOR_SCROLL_OFF {}

WAIT_FOR_SCROLL_CHANGE {}

LED_OFF {}

LED_G { return led_green; }

LED_R { return led_red; }

HOLD\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[5]);
    return hold;
} 

RELEASE\ [[:graph:]|[:blank:]]+ {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, &yytext[8]);
    return release;
}

\n|(\r\n) {}

[[:blank:]]+ {
    return separator;
}

[[:alpha:]] {
    yylval.text = (char *)malloc(sizeof(char)*(strlen(yytext)+1));
    strcpy(yylval.text, yytext);
    return letter;
}

%%
