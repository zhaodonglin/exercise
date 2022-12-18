#include <stdio.h>

#define PROG_SIZE (1024*1024*16)
#define TOKEN_SIZE (1024)

char PROG_BUFFER[PROG_SIZE];

typedef enum token_type {
    OPERATOR,
    DELIMETER,
    VARIABLE,
    QUOTE,
    NUMBER,
    KEYWORD,
    STRING,
    LINE_BREAK,
    END,
}TOKEN_TYPE;

typedef struct token {
    char data[TOKEN_SIZE];
    char *next;
    TOKEN_TYPE type;
}TOKEN;

bool is_white(char *p) {
    return NULL != strchr(' \t', *p);
}

Token get_token(char* p) {
    Token token;
    char* next = p;
    //skip whitespace and tab
    while (is_white(*next)) {
        next++;
    }  
    if (isdigit(*next)) {
        while(isdigit(*next)) {
            next++;
        }
        strncpy(token.data, p, next-p);
        token.next = next;
        token.type = NUMBER;
    } else if (strchr('\n\r', *next)){
        token.next = next +1;
        token.type = LINE_BREAK;
    } else if (isalpha(*next)) {
        while (isalpha(*next)) {
            next++;
        }
        strncpy(token.data, p, next-p);
        token.next = next;
        token.type = STRING;
    }

    return token
}

typedef struct label{
    int label;
    char *p;
}LABEL;

#define MAX_LABEL_NUMBER 256
LABEL labels[MAX_LABEL_NUMBER];

void add_to_label(TOKEN *token) {
    static int cursor;
    int label = atoi(toke->data);
    char *p = token->next;
    labels[cursor++].p = p;
    labels[label] = label;
}

void scan_labels(char *p){
    // scan from start to end
    // the first of line
    // the previous token is line_break and current token is digit,
    // then this is a label
    TOKEN token = get_token(p);
    if (token.type == NUMBER) {
        add_to_lable(&token);
    }
    while (*p!= '\0') {
        token = get_token(p):
        if (token.type == LINE_BREAK) {
            next_token = get_token(p);
            if (next_token.type == NUMBER) {
                add_to_label(&next_token);
            } 
        }
    }
}

void process_keyword(char *token) {
    switch(token->data) {
        case "PRINT":
            print(token);
            break;
        case "FOR":
            break;
        case "IF":
            break;
    }
}

int load_program(char* p, char* file_name) {
    FILE *fp = fopen(file_name, 'r');
    if (fp == NULL) {
        printf("Failed to open file");
        return -1;
    }

    int i = 0;
    while (i < PROG_SIZE) {
        *p = fgetc(fp);
        if (feof(fp)) {
            break;
        }
        p++;
        i++;
    }
    *(p-1) = '\0';
    return 0;
}


#define MAX_VARIABLE_NUMBER
typedef struct variable {
    char name[TOKEN_SIZE];
    int value;
}VARIABLE;

VARIABLE variable_table[MAX_VARIABLE_NUMBER];

void save_to_variable_table(char *name, int value) {
    static int cursor;
    VARIABLE variable = variable_table[cursor++];
    strncpy(variable.name, name, TOKEN_SIZE);
    variable.value = value;
}

void assignment(Token* token) {
    char name[TOKEN_SIZE];
    strncpy(name, token.data, TOKEN_SIZE);

    Token *token = get_token(token.next);
    if ((token.type != OPERATOR) or (strcmp(token.data, '=') != 0)){
        print("Invalid assignment, expect '=' " );
        return;
    }
    int value = eval_expression(token->next);
    save_to_variable_table(name, value);
}

typedef struct for_stack {
    char *loc;
    int count;
    int target;    
}FOR_STACK;

#define STACK_SIZE 256;
FOR_STACK for_stack[STACK_SIZE];

void exec_for(Token* token){
    Token token = get_token(token.next);
    if (token->type != VARIABLE) {
        printf('invalid for, expect variable.');
        return;
    }
    token = get_token(token->next);
    if ((token->type != OPERATOR) || (strcmp(token->data, '=')!=0)) {
        print("invalid for, expect '='." );
        return;
    } 
    int intial_val = eval_expression(token->next);
    token = get_token(token->next);
    if ((token->type != OPERATOR) || (strcmp(token->data, 'To')!=0)) {
        print("invalid for, expect '='To" );
        return;
    }
    int end_val = eval_expression(token->next);

    if (initial_val < end_val) {

    }

}
void print(Token* token) {
    do {
        Token *token=get_token(token.next);

        if (token->type==QUOTE) {
            printf("%s", token->data);
        } else if (token->type == DELIMETER) {
            if (strcmp(token->data, "","") == 0) {
                for (int i = 0; i < 8; i++) {
                    printf(" ");
                }
            }else if(strcmp(token->data, ";")== 0) {
                printf(" ");
            }
        } else {
            int value = eval_expression(token->next);
            printf("%d", value);
        }

    }while(token->type != END and token->type != LINE_BREAK);
}

void interprete(char *prog) {
    // interprete tokens one by one
    TOKEN token;

    do {
        token = get_token(prog);
        //the first token should be NUMBER or KEYWORD or VARIABLE
        //NUMBER is the label, label is processed in the first traverse.
        if (token.type == VARIABLE) {
            assignment(&token);
        } else if (token.type == KEYWORD) {
            process_keyword(&token);
        }
        
    }while(token.type != END)
}




int main(int argc, char *argv[]) {
    memset((void*)PROG_BUFFER, 0, PROG_SIZE);

    if (argc != 2) {
        print("Please input filename.");
    }
    
    file_name = argv[1];
    char *prog = PROG_BUFFER;
    load_program(prog, file_name);
    scan_labels(prog);
    #3 interpreter
}

