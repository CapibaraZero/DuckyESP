%{
    #include <stdio.h>
    #include <string>
    #include <string.h>
    #include <bits/stdc++.h>
    #include <stdlib.h>
    #include <map>

    std::map<std::string, int> num_constants;
    std::map<std::string, std::string> string_constants;

    extern "C" int yylex();
    int yyerror(char *s);

    void header();
    void print_default_delay();
    void print_string(char *s);
    void print_stringln(char *s);
    void footer();

    int d = 0;
    int min = 0;
    int max = 65535;
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
	return rand() % (max + 1 - min) + min;
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
    
    /* Convert modifiers to real value. TODO: Put real SDK value here. */
    uint8_t key_to_value(char *raw_val) {
	if(!strcmp(raw_val, "UPARROW"))
	    return 0;
	if(!strcmp(raw_val, "DOWNARROW"))
	    return 0;
	if(!strcmp(raw_val, "LEFTARROW"))
	    return 0;
	if(!strcmp(raw_val, "RIGHTARROW"))
	    return 0;
	if(!strcmp(raw_val, "PAGEUP"))
	    return 0;
	if(!strcmp(raw_val, "PAGEDOWN"))
	    return 0;
	if(!strcmp(raw_val, "HOME"))
	    return 0;
	if(!strcmp(raw_val, "END"))
	    return 0;
	if(!strcmp(raw_val, "INSERT"))
	    return 0;
	if(!strcmp(raw_val, "DELETE"))
	    return 0;
	if(!strcmp(raw_val, "BACKSPACE"))
	    return 0;
	if(!strcmp(raw_val, "TAB"))
	    return 0;
	if(!strcmp(raw_val, "SPACE"))
	    return 0;
	if(!strcmp(raw_val, "ENTER"))
	    return 0;
	if(!strcmp(raw_val, "ESCAPE"))
	    return 0;
	if(!strcmp(raw_val, "PAUSE"))
	    return 0;
	if(!strcmp(raw_val, "BREAK"))
	    return 0;
	if(!strcmp(raw_val, "PRINTSCREEN"))
	    return 0;
	if(!strcmp(raw_val, "MENU"))
	    return 0;
	if(!strcmp(raw_val, "APP"))
	    return 0;
	if(!strcmp(raw_val, "F1"))
	    return 0;
	if(!strcmp(raw_val, "F2"))
	    return 0;
	if(!strcmp(raw_val, "F3"))
	    return 0;
	if(!strcmp(raw_val, "F4"))
	    return 0;
	if(!strcmp(raw_val, "F5"))
	    return 0;
	if(!strcmp(raw_val, "F6"))
	    return 0;
	if(!strcmp(raw_val, "F7"))
	    return 0;
	if(!strcmp(raw_val, "F8"))
	    return 0;
	if(!strcmp(raw_val, "F9"))
	    return 0;
	if(!strcmp(raw_val, "F10"))
	    return 0;
	if(!strcmp(raw_val, "F11"))
	    return 0;
	if(!strcmp(raw_val, "F12"))
	    return 0;
	if(!strcmp(raw_val, "SHIFT"))
	    return 0;
	if(!strcmp(raw_val, "ALT"))
	    return 0;
	if(!strcmp(raw_val, "CONTROL"))
	    return 0;
	if(!strcmp(raw_val, "CTRL"))
	    return 0;
	if(!strcmp(raw_val, "WINDOWS"))
	    return 0;
	if(!strcmp(raw_val, "GUI"))
	    return 0;
    
	return 1;
    }
%}

%token alt altgr backspace default_delay delay_key menu pause_key capslock ctrl delete_key down end enter esc function gui home insert led_red led_green left letter new_line numlock pagedown pageup printscreen repeat right scrolllock separator shift space string multiline_string multiline_stringln stringln tab up if_statement release hold
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
file: {header();} blocs {footer();}

blocs: bloc blocs
     | bloc

bloc: line repeat new_line
    | line
    | expr
    | modes
    | combos

line: keys {printf("  Keyboard.releaseAll();\n");print_default_delay();} new_line
    | delay_key {printf("  delay(%d);\n", yylval.integer*10);} new_line
    | default_delay {d = yylval.integer*10;} new_line
    | string {print_string(yylval.text);print_default_delay();} new_line
    | multiline_string { 
	initial_trim(yylval.text);
	printf("Keyboard.press(\"%s\");\n",yylval.text); 
    }
    | multiline_stringln { 
	initial_trim(yylval.text);
	printf("Keyboard.press(\"%s\");\nKeyboard.press(KEY_RETURN);\n",yylval.text); 
    }
    | stringln {print_stringln(yylval.text);print_default_delay();} new_line
    | new_line {printf("\n");}
    | btn
    | payload_control
    | jitter
    | randomization

keys: key separator keys
    | key 

key: alt {printf("  Keyboard.press(KEY_LEFT_ALT);\n");}
   | altgr {printf("  Keyboard.press(KEY_RIGHT_ALT);\n");}
   | backspace {printf("  Keyboard.press(KEY_BACKSPACE);\n");}
   | menu {printf("  Keyboard.press(0x76+0x88);\n");}
   | pause_key {printf("  Keyboard.press(0x48+0x88);\n");}
   | capslock {printf("  Keyboard.press(KEY_CAPS_LOCK);\n");}
   | ctrl {printf("  Keyboard.press(KEY_LEFT_CTRL);\n");}
   | delete_key {printf("  Keyboard.press(KEY_DELETE);\n");}
   | down {printf("  Keyboard.press(KEY_DOWN_ARROW);\n");}
   | end {printf("  Keyboard.press(KEY_END);\n");}
   | enter {printf("  Keyboard.press(KEY_RETURN);\n");}
   | esc {printf("  Keyboard.press(KEY_ESC);\n");}
   | function {printf("  Keyboard.press(KEY_F%d);\n", yylval.integer);}
   | gui {printf("  Keyboard.press(KEY_LEFT_GUI);\n");}
   | home {printf("  Keyboard.press(KEY_HOME);\n");}
   | insert {printf("  Keyboard.press(KEY_INSERT);\n");}
   | left {printf("  Keyboard.press(KEY_LEFT_ARROW);\n");}
   | numlock {printf("  Keyboard.press(0x53+0x88);\n");}
   | pagedown {printf("  Keyboard.press(KEY_PAGE_DOWN);\n");}
   | pageup {printf("  Keyboard.press(KEY_PAGE_UP);\n");}
   | printscreen {printf("  Keyboard.press(0x46+0x88);\n");}
   | right {printf("  Keyboard.press(KEY_RIGHT_ARROW);\n");}
   | scrolllock {printf("  Keyboard.press(0x47+0x88);\n");}
   | shift {printf("  Keyboard.press(KEY_LEFT_SHIFT);\n");}
   | space {printf("  Keyboard.press(' ');\n");}
   | tab {printf("  Keyboard.press(KEY_TAB);\n");}
   | up {printf("  Keyboard.press(KEY_UP_ARROW);\n");}
   | letter {printf("  Keyboard.press('%s');\n", yylval.text);}
   | hold {
	int value = key_to_value(yylval.text);
	printf(" Keyboard.press('%i');\n", value);

    }
   | release {
	int value = key_to_value(yylval.text);
	printf("keyboard.release('%i');\n", value);
    }
   | led_green { printf("digitalWrite(LED_R_PIN, LOW);\ndigitalWrite(LED_G_PIN, HIGH);\n");}
   | led_red { printf("digitalWrite(LED_G_PIN, LOW);\ndigitalWrite(LED_R_PIN, HIGH);\n"); }

expr: num_var {printf("int %s;", yylval.text);}
    | str_var { printf("std::string %s\";", yylval.text);}
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
	std::cout << "Constants: " << define_name  << " "  << string_constants[define_name]  << std::endl;
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
	std::cout << "Constants: " << define_name  << " "  << num_constants[define_name]  << std::endl;
    }
    | math_operator {printf("%s;", yylval.text);}
    | if_statement {printf("if%s{\n", yylval.text);}
    | end_if {printf("}\n");} 

modes: attackmode {
	if(strcmp(yylval.text, "STORAGE") == 0)
	    printf("STORAGE\n");
	else if(strcmp(yylval.text, "HID") == 0)
	    printf("HID\n");
	else
	   yyerror("Invalid ATTACKMODE"); 
     }

combos: ctrl_alt {printf("ctrl_alt: %s\n", yylval.text);}
	| ctrl_shift {printf("ctrl_shift: %s\n", yylval.text);}
	| alt_shift {printf("alt_shift: %s\n", yylval.text);}

btn: wait_for_button_press {printf("Wait for button press.\n");}
   | enable_button {
	button_enabled = true;
	printf("Enable button.\n");
   }
   | disable_button {
	button_enabled = false;
	printf("Disable button.\n");
    }

payload_control: restart_payload {printf("Restart payload\n");}
	       | stop_payload {printf("Stop payload\n");}
	       | reset {printf("Reset\n");}

jitter: jitter_enabled_key { 
	if(strstr(yylval.text, "TRUE")!= NULL){
	    printf("jitter true\n");
	    jitter_enabled = true;
	}else {
	    jitter_enabled = false;
	    printf("jitter false\n");
	}
      }
      | jitter_max_key { 
	    printf("Jitter max: %s\n", yylval.text);
	    jitter_max = atoi(yylval.text);
      }

randomization: random_lowercase_letter_keyword {
		printf("Keyboard.print(%c);\n", random_lowercase_letter());
	    }
	    | random_uppercase_letter_keyword {
		printf("Keyboard.print(%c);\n", random_uppercase_letter());
	    }
	    | random_letter_keyword {
		printf("Keyboard.print(%c);\n", random_letter());
	    }
	    | random_number_keyword {
		printf("Keyboard.print(%i);\n", random_number());
	    }
	    | random_special_keyword {
		printf("Keyboard.print(%c);\n", random_special());
	    }
	    | random_char_keyword {
		printf("Keyboard.print(random_char());\n");
	    }
%%

int yyerror(char *s) {
    printf("\033[31merror:\033[0m %s \033[0m\n",s);
    return 0;
}

void header() {
    printf("#include <Keyboard.h>\n\n");
    printf("#define LED_G_PIN 2\n");
    printf("#define LED_R_PIN 3\n");
    printf("void setup() {\n");
    printf("  // keyboard connection\n");
    printf("  Keyboard.begin();\n");
    printf("  delay(500);\n\n");
}

void print_default_delay() {
    if (d != 0) {
        printf("  delay(%d);\n", d);
    }
}

void print_string(char *s) {
    printf("  Keyboard.print(\"");
    find_and_replace_constant(s);
    int i = 0;
    while (s[i] != '\0') {
        if (s[i] == '\"' || s[i] == '\\') {
            printf("\\");
        }
        printf("%c", s[i]);
        i++;
    }

    printf("\");\n");
}

void print_stringln(char *s) {
    printf("  Keyboard.print(\"");

    int i = 0;
    while (s[i] != '\0') {
        if (s[i] == '\"' || s[i] == '\\') {
            printf("\\");
        }
        printf("%c", s[i]);
        i++;
    }

    printf("\");\n");
    printf("Keyboard.press(ENTER);\n");
}

void footer() {
    printf("\n");
    printf("  // keyboard disconnection\n");
    printf("  Keyboard.end();\n");
    printf("}\n\n");
    printf("void loop() {}\n");
}

int main(void) {
    yyparse();
    return 0;
}
