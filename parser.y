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

    #include <stdio.h>
    #include <string>
    #include <string.h>
    #include <bits/stdc++.h>
    #include <stdlib.h>
    #include <map>
    #include "usb_hid/USBHid.hpp" 
    #include "SDBridge32.hpp"
    #include "Arduino.h"

    std::map<std::string, int> num_constants;
    std::map<std::string, std::string> string_constants;
    
    #define KEY_SPACE 0x20
    #define KEY_MENU 0x76+0x88
    #define KEY_PAUSE 0x48+0x88
    #define KEY_NUMLOCK 0x53+0x88
    #define KEY_PRINTSCREEN 0x46+0x88
    #define KEY_SCROLLLOCK 0x47+0x88
	#ifdef ARDUINO_NANO_ESP32
	#define SERIAL_DEVICE Serial
	#else
	#define SERIAL_DEVICE Serial0
	#endif
    /* Mock values */
    #define LED_G_PIN 2
    #define LED_R_PIN 3

    extern "C" int yylex();
    int yyerror(char *s);
    extern FILE *yyin;

    void print_default_delay();
    
    USBHid hid = USBHid();
    SDBridge32 msc = SDBridge32();
    
    int d = 0;
    int rand_min = 0;
    int rand_max = 65535;
    bool button_enabled = false;
    bool button_push_received = false;
    bool jitter_enabled = false;
    int jitter_max = 20000;	// 20 seconds in milliseconds

    char random_lowercase_letter() {
	return rand() % (122 + 1 - 97) + 97;
    }

    char random_uppercase_letter() {
	return rand() % (90 + 1 - 65) + 65;
    }

    char random_letter() {
	return rand() % (122 + 1 - 65) + 65;
    }

    int random_number() {
	return rand() % 10;
    }

    char random_special() {
	int chars[10] = {33, 64, 35, 36, 37, 94, 38, 42, 40, 41};
	return chars[rand() % 11];
    }

    int random_number_range() {
	return rand() % (rand_max + 1 - rand_min) + rand_min;
    }

    bool find_and_replace_constant(char *str) {
	const char *found_pos = NULL;
	for(auto i = string_constants.begin(); i != string_constants.end(); i++){
	   if((found_pos = strstr(str, ("#" + i->first).c_str())) != NULL){
		strcpy((char *)found_pos, i->second.c_str());
		return true;
	    }
	}

	for(auto i = num_constants.begin(); i != num_constants.end(); i++){
	   if((found_pos = strstr(str, ("#" + i->first).c_str())) != NULL){
		char int_ascii[1] = { (char)('0' + i->second) };
		strcpy((char *)found_pos, int_ascii);
		return true; 
	    } 
	}
	return false;
    }

    void initial_trim(char *str) {
	for(int i = 0; i < strlen(str); i++) {
	    if(str[i] == ' ') {	
		memmove(str, str+1, strlen(str));
	    }else {
		memmove(str, str+2, strlen(str));
		return;
	    }
	} 
    }
    
    /* Convert modifiers to real value. */
    uint8_t key_to_value(char *raw_val) {
	if(!strcmp(raw_val, "UPARROW"))
	    return KEY_UP_ARROW;
	if(!strcmp(raw_val, "DOWNARROW"))
	    return KEY_DOWN_ARROW;
	if(!strcmp(raw_val, "LEFTARROW"))
	    return KEY_LEFT_ARROW;
	if(!strcmp(raw_val, "RIGHTARROW"))
	    return KEY_RIGHT_ARROW;
	if(!strcmp(raw_val, "PAGEUP"))
	    return KEY_PAGE_UP;
	if(!strcmp(raw_val, "PAGEDOWN"))
	    return KEY_PAGE_DOWN;
	if(!strcmp(raw_val, "HOME"))
	    return KEY_HOME;
	if(!strcmp(raw_val, "END"))
	    return KEY_END;
	if(!strcmp(raw_val, "INSERT"))
	    return KEY_INSERT;
	if(!strcmp(raw_val, "DELETE"))
	    return KEY_DELETE;
	if(!strcmp(raw_val, "BACKSPACE"))
	    return KEY_BACKSPACE;
	if(!strcmp(raw_val, "TAB"))
	    return KEY_TAB;
	if(!strcmp(raw_val, "SPACE"))
	    return KEY_SPACE;
	if(!strcmp(raw_val, "ENTER"))
	    return KEY_RETURN;
	if(!strcmp(raw_val, "ESCAPE"))
	    return 0;
	if(!strcmp(raw_val, "PAUSE"))
	    return 0;
	if(!strcmp(raw_val, "BREAK"))
	    return 0;
	if(!strcmp(raw_val, "PRINTSCREEN"))
	    return 0;
	if(!strcmp(raw_val, "MENU"))
	    return KEY_MENU;
	if(!strcmp(raw_val, "APP"))
	    return 0;
	if(!strcmp(raw_val, "F1"))
	    return KEY_F1;
	if(!strcmp(raw_val, "F2"))
	    return KEY_F2;
	if(!strcmp(raw_val, "F3"))
	    return KEY_F3;
	if(!strcmp(raw_val, "F4"))
	    return KEY_F4;
	if(!strcmp(raw_val, "F5"))
	    return KEY_F5;
	if(!strcmp(raw_val, "F6"))
	    return KEY_F6;
	if(!strcmp(raw_val, "F7"))
	    return KEY_F7;
	if(!strcmp(raw_val, "F8"))
	    return KEY_F8;
	if(!strcmp(raw_val, "F9"))
	    return KEY_F9;
	if(!strcmp(raw_val, "F10"))
	    return KEY_F10;
	if(!strcmp(raw_val, "F11"))
	    return KEY_F11;
	if(!strcmp(raw_val, "F12"))
	    return KEY_F12;
	if(!strcmp(raw_val, "SHIFT"))
	    return KEY_LEFT_SHIFT;
	if(!strcmp(raw_val, "ALT"))
	    return KEY_LEFT_ALT;
	if(!strcmp(raw_val, "CONTROL"))
	    return KEY_LEFT_CTRL;
	if(!strcmp(raw_val, "CTRL"))
	    return KEY_LEFT_CTRL;
	if(!strcmp(raw_val, "WINDOWS"))
	    return KEY_LEFT_GUI;
	if(!strcmp(raw_val, "GUI"))
	    return KEY_LEFT_GUI;
    
	return 1;
    }
%}

%token alt altgr backspace default_delay delay_key menu pause_key capslock ctrl delete_key down end enter esc function gui home insert led_red led_green left letter  numlock pagedown pageup printscreen repeat right scrolllock separator shift space string multiline_string multiline_stringln stringln tab up if_statement release hold
%token<s> num_var str_var num_define str_define math_operator end_if
%type<i> expr
// Attack mode
%type<s> modes
%token<s> attackmode
// Combo modifiers
%type<s> combos
%token<s> ctrl_alt ctrl_shift alt_shift
// Button
%type btn
%token wait_for_button_press enable_button disable_button
// Payload control
%type payload_control
%token restart_payload stop_payload reset
// Jitter 
%type jitter
%token jitter_enabled_key jitter_max_key
// Randomization
%type randomization
%token random_lowercase_letter_keyword random_uppercase_letter_keyword random_letter_keyword random_number_keyword random_special_keyword random_char_keyword 
// required to get text
%union {
    char *text;
    int integer;
}

%%
file: {} blocs {}

blocs: bloc blocs
     | bloc

bloc: line repeat 
    | line
    | expr
    | modes
    | combos

line: keys {
	hid.release_all();
	print_default_delay();
    } 
    | delay_key {delay(yylval.integer);} 
    | default_delay {d = yylval.integer;} 
    | string {
	hid.print_string(yylval.text);
	print_default_delay();
    } 
    | multiline_string { 
	initial_trim(yylval.text);
	hid.print_string(yylval.text); 
    }
    | multiline_stringln { 
	initial_trim(yylval.text);
	hid.print_string(yylval.text);
	hid.press(KEY_RETURN); 
    }
    | stringln {hid.print_string(yylval.text);
		print_default_delay();
    } 
    | btn
    | payload_control
    | jitter
    | randomization

keys: key separator keys
    | key 

key: alt {hid.press(KEY_LEFT_ALT);}
   | altgr {hid.press(KEY_RIGHT_ALT);}
   | backspace {hid.press(KEY_BACKSPACE);}
   | menu {hid.press(KEY_MENU);}
   | pause_key {hid.press(KEY_PAUSE);}
   | capslock {hid.press(KEY_CAPS_LOCK);}
   | ctrl {hid.press(KEY_LEFT_CTRL);}
   | delete_key {hid.press(KEY_DELETE);}
   | down {hid.press(KEY_DOWN_ARROW);}
   | end {hid.press(KEY_END);}
   | enter {hid.press(KEY_RETURN);}
   | esc {hid.press(KEY_ESC);}
   | function {
	//0xC1 is F1(0xC2) - 1. So if we addiction function key number, we can obtain the keyboard code for function keys 
	hid.press(0xC1 + yylval.integer);	
    }
   | gui {hid.press(KEY_LEFT_GUI);}
   | home {hid.press(KEY_HOME);}
   | insert {hid.press(KEY_INSERT);}
   | left {hid.press(KEY_LEFT_ARROW);}
   | numlock {hid.press(KEY_NUMLOCK);}
   | pagedown {hid.press(KEY_PAGE_DOWN);}
   | pageup {hid.press(KEY_PAGE_UP);}
   | printscreen {hid.press(KEY_PRINTSCREEN);}
   | right {hid.press(KEY_RIGHT_ARROW);}
   | scrolllock {hid.press(KEY_SCROLLLOCK);}
   | shift {hid.press(KEY_LEFT_SHIFT);}
   | space {hid.press(' ');}
   | tab {hid.press(KEY_TAB);}
   | up {hid.press(KEY_UP_ARROW);}
   | letter {hid.press(yylval.text[0]);}
   | hold {
	int value = key_to_value(yylval.text);
	hid.press(value);

    }
   | release {
	int value = key_to_value(yylval.text);
	hid.release(value);
    }
   | led_green { digitalWrite(LED_R_PIN, LOW);
		 digitalWrite(LED_G_PIN, HIGH);
    }
   | led_red { digitalWrite(LED_G_PIN, LOW);
	       digitalWrite(LED_R_PIN, HIGH);
    }

expr: num_var {SERIAL_DEVICE.printf("NOT IMPLEMENTED: int %s;", yylval.text);}
    | str_var { SERIAL_DEVICE.printf("NOT IMPLEMENTED: std::string %s\";", yylval.text);}
    | str_define {
	std::stringstream define = std::stringstream(yylval.text);
	std::string temp_str;
	std::string define_name;
	int i = 0;
	while(getline(define, temp_str, ' ')) {
	    if(i++ == 0) {
		define_name = temp_str;
	    } else if(i++ == 1)
		continue;
	}
	string_constants[define_name] = temp_str;
    }
    | num_define {
	std::stringstream define = std::stringstream(yylval.text);
	std::string temp_str;
	std::string define_name;
	int i = 0;
	while(getline(define, temp_str, ' ')) {
	    if(i++ == 0) {
		define_name = temp_str;
	    } else if(i++ == 1)
		continue;
	}
	num_constants[define_name] = atoi(temp_str.c_str());
    }
    | math_operator {SERIAL_DEVICE.printf("NOT IMPLEMENTED MATH OPERATOR %s;", yylval.text);}
    | if_statement {SERIAL_DEVICE.printf("NOT IMPLEMENTED: if%s{\n", yylval.text);}
    | end_if {SERIAL_DEVICE.printf("NOT IMPLEMENTED }\n");} 

modes: attackmode {
	if(strcmp(yylval.text, "STORAGE") == 0){
		hid.end();
		msc.begin("CapibaraZero", "DuckyESP", "1.1.0");
	}
	else if(strcmp(yylval.text, "HID") == 0) {
		msc.end();
		hid.begin();
	}
	else
	   yyerror("Invalid ATTACKMODE"); 
    }

combos: ctrl_alt {
	    hid.press(KEY_LEFT_CTRL);
	    hid.press(KEY_LEFT_ALT);
	    hid.press(key_to_value(yylval.text));
	    hid.release_all();
	}
	| ctrl_shift {
	    hid.press(KEY_LEFT_CTRL);
	    hid.press(KEY_LEFT_SHIFT);
	    hid.press(key_to_value(yylval.text));
	    hid.release_all();
	}
	| alt_shift {
	    hid.press(KEY_LEFT_ALT);
	    hid.press(KEY_LEFT_SHIFT);
	    hid.press(key_to_value(yylval.text));
	    hid.release_all();
	}

/* TODO: Make implementation of this */
btn: wait_for_button_press {SERIAL_DEVICE.println("NOT IMPLEMENTED: Wait for button press.\n");}
   | enable_button {
	button_enabled = true;
	SERIAL_DEVICE.println("NOT IMPLEMENTED: Enable button.");
   }
   | disable_button {
	button_enabled = false;
	SERIAL_DEVICE.println("NOT IMPLEMENTED Disable button.");
    }

payload_control: restart_payload {
		    SERIAL_DEVICE.println("NOT IMPLEMENTED: Restart payload");
		    rewind(yyin);	// Reset FILE pointer to position 0
		}
	       | stop_payload {
		   YYACCEPT;	// Stop parser 
		}
	       | reset {
		    hid.release_all();	// Probably not the same meaning of DuckyScript
		}

jitter: jitter_enabled_key { 
	if(strstr(yylval.text, "TRUE")!= NULL){
	    jitter_enabled = true;
	}else {
	    jitter_enabled = false;
	}
      }
      | jitter_max_key { 
	    jitter_max = atoi(yylval.text);
      }

randomization: random_lowercase_letter_keyword {
		hid.print_char(random_lowercase_letter());
	    }
	    | random_uppercase_letter_keyword {
		hid.print_char(random_uppercase_letter());
	    }
	    | random_letter_keyword {
		hid.print_char(random_letter());
	    }
	    | random_number_keyword {
		hid.print_char(random_number());
	    }
	    | random_special_keyword {
		hid.print_char(random_special());
	    }
	    | random_char_keyword {
		SERIAL_DEVICE.println("NOT IMPLEMENTED: Keyboard.print(random_char());\n");
	    }
%%

int yyerror(char *s) {
    SERIAL_DEVICE.printf("\033[31merror:\033[0m %s \033[0m",s);
    raise(SIGSEGV);
    return 0;
}

void print_default_delay() {
    if (d != 0)
        delay(d);
}
