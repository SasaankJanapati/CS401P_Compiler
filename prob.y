%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
typedef struct node Node;
typedef struct list List;
#define TABLE_SIZE 1000  // Define the size of the hash table

int yylex();
void yyerror(const char *s);
extern FILE *yyin;
int error_flag = 0;
int labels = 0;
char var_list[1000][1000];
int var_count = 0;
char intermediate_code[10000][10000];
int idx = 0;
// int yydebug = 1;

typedef struct Type {
    char type[1000];
    int width;
} Type;

// Function to create a new Type instance
Type* createType(char* value, int width) {
    Type* n = (Type*)malloc(sizeof(Type)); // Allocate memory for the Type
    if (n == NULL) { // Check if malloc was successful
        fprintf(stderr, "Memory allocation failed\n");
        return NULL;
    }
    
    // Copy the value into the type field
    strncpy(n->type, value, sizeof(n->type) - 1); // Use strncpy to prevent buffer overflow
    n->type[sizeof(n->type) - 1] = '\0'; // Ensure null termination
    n->width = width; // Set the width

    return n; // Return the newly created Type instance
}

typedef struct HashNode {
    char* name;        // Symbol name
    char* type;        // Type of the symbol (e.g., int, float, etc.)
    int offset;        // Offset for the symbol
    struct HashNode* next; // Pointer to the next node (for collision resolution)
} HashNode;

typedef struct SymbolTable {
    HashNode** table;  // Pointer to an array of hash nodes
} SymbolTable;

// Function to create a new HashNode
HashNode* createHashNode(const char* name, const char* type, int offset) {
    HashNode* newNode = (HashNode*)malloc(sizeof(HashNode));
    newNode->name = strdup(name); // Duplicate the string for the name
    newNode->type = strdup(type); // Duplicate the string for the type
    newNode->offset = offset;
    newNode->next = NULL; // Initialize next to NULL
    return newNode;
}

// Function to create a symbol table
SymbolTable* createSymbolTable() {
    SymbolTable* symbolTable = (SymbolTable*)malloc(sizeof(SymbolTable));
    symbolTable->table = (HashNode**)malloc(TABLE_SIZE * sizeof(HashNode*));

    for (int i = 0; i < TABLE_SIZE; i++) {
        symbolTable->table[i] = NULL; // Initialize all table entries to NULL
    }

    return symbolTable;
}

// Hash function to compute the index for a given name
unsigned int hash(const char* name) {
    unsigned int hashValue = 0;
    while (*name) {
        hashValue = (hashValue << 5) + *name++; // Hashing algorithm
    }
    return hashValue % TABLE_SIZE; // Return index within the table size
}

// Function to lookup a symbol by name, returns the symbol if found, NULL if not found
HashNode* lookupSymbol(SymbolTable* symbolTable, const char* name) {
    if(symbolTable == NULL) return NULL;
    unsigned int index = hash(name);
    HashNode* current = symbolTable->table[index];

    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current; // Symbol found
        }
        current = current->next; // Move to the next node
    }
    return NULL; // Symbol not found
}

// Function to insert a new symbol into the symbol table
// Returns:
// 0 - Successfully inserted the symbol
// 1 - Symbol redeclared with the same type
// 2 - Symbol has conflicting types
int insertSymbol(SymbolTable* symbolTable, const char* name, const char* type, int offset) {
    // Look up the symbol to check if it already exists
    HashNode* existingSymbol = lookupSymbol(symbolTable, name);

    if (existingSymbol) {
        // Symbol exists, check if the type matches
        if (strcmp(existingSymbol->type, type) == 0) {
            // Same type, so it's just a redeclaration
            return 1; // Redeclared with the same type
        } else {
            // Different type, so it's a conflicting declaration
            return 2; // Conflicting types
        }
    }

    // Symbol does not exist, insert it
    unsigned int index = hash(name);
    HashNode* newNode = createHashNode(name, type, offset);

    // Collision resolution: add the new node at the beginning of the linked list
    newNode->next = symbolTable->table[index];
    symbolTable->table[index] = newNode;

    return 0; // Successfully inserted the symbol
}


// Function to delete a symbol from the symbol table
void deleteSymbol(SymbolTable* symbolTable, const char* name) {
    unsigned int index = hash(name);
    HashNode* current = symbolTable->table[index];
    HashNode* previous = NULL;

    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            if (previous == NULL) {
                // Remove the head of the list
                symbolTable->table[index] = current->next;
            } else {
                // Remove the node from the middle or end
                previous->next = current->next;
            }
            free(current->name);
            free(current->type);
            free(current);
            return; // Symbol deleted
        }
        previous = current;
        current = current->next;
    }
}

// Function to free the symbol table
void freeSymbolTable(SymbolTable* symbolTable) {
    for (int i = 0; i < TABLE_SIZE; i++) {
        HashNode* current = symbolTable->table[i];
        while (current != NULL) {
            HashNode* temp = current;
            current = current->next;
            free(temp->name);
            free(temp->type);
            free(temp);
        }
    }
    free(symbolTable->table);
    free(symbolTable);
}

// Define a node in the ScopeStack linked list
typedef struct ScopeStackNode {
    SymbolTable* table;
    struct ScopeStackNode* next;
} ScopeStackNode;

// Define the ScopeStack structure itself
typedef struct ScopeStack {
    ScopeStackNode* top; // Pointer to the top node
} ScopeStack;

// Function to create a new ScopeStack
ScopeStack* createScopeStack() {
    ScopeStack* stack = (ScopeStack*)malloc(sizeof(ScopeStack));
    stack->top = NULL; // Initialize top as NULL (empty stack)
    return stack;
}

// Function to check if the ScopeStack is empty
int isScopeStackEmpty(ScopeStack* stack) {
    return stack->top == NULL;
}

// Function to push a new symbol table onto the ScopeStack
void pushScope(ScopeStack* stack, SymbolTable* symbolTable) {
    ScopeStackNode* node = (ScopeStackNode*)malloc(sizeof(ScopeStackNode));
    node->table = symbolTable;
    node->next = stack->top; // Link new node to the current top
    stack->top = node;       // Update top to the new node
}

// Function to pop a symbol table from the ScopeStack
SymbolTable* popScope(ScopeStack* stack) {
    if (isScopeStackEmpty(stack)) {
        printf("ScopeStack underflow\n");
        return NULL; // Return NULL if the stack is empty
    }
    ScopeStackNode* temp = stack->top;
    SymbolTable* poppedTable = temp->table;
    stack->top = stack->top->next; // Move top to the next node
    // free(temp);
    return poppedTable;
}

// Function to peek at the top symbol table of the ScopeStack
SymbolTable* peekScope(ScopeStack* stack) {
    if (isScopeStackEmpty(stack)) {
        printf("ScopeStack is empty\n");
        return NULL; // Return NULL if the stack is empty
    }
    return stack->top->table;
}

// Function to free the ScopeStack
void freeScopeStack(ScopeStack* stack) {
    while (!isScopeStackEmpty(stack)) {
        popScope(stack); // Free each symbol table in the stack
    }
    free(stack);
}

typedef struct OffsetStackNode {
    int offset;
    struct OffsetStackNode* next;
} OffsetStackNode;

typedef struct OffsetStack {
    OffsetStackNode* top;
} OffsetStack;

// Function to create a new stack node
OffsetStackNode* createOffsetStackNode(int offset) {
    OffsetStackNode* node = (OffsetStackNode*)malloc(sizeof(OffsetStackNode));
    if (!node) {
        printf("Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }
    node->offset = offset;
    node->next = NULL;
    return node;
}

// Function to initialize the stack
OffsetStack* createOffsetStack() {
    OffsetStack* stack = (OffsetStack*)malloc(sizeof(OffsetStack));
    if (!stack) {
        printf("Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }
    stack->top = NULL;
    return stack;
}

// Function to check if the stack is empty
bool isOffsetStackEmpty(OffsetStack* stack) {
    return stack->top == NULL;
}

// Function to push an offset onto the stack
void pushOffset(OffsetStack* stack, int offset) {
    OffsetStackNode* node = createOffsetStackNode(offset);
    node->next = stack->top;
    stack->top = node;
}

// Function to pop the top offset from the stack
int popOffset(OffsetStack* stack) {
    if (isOffsetStackEmpty(stack)) {
        printf("Stack underflow\n");
        exit(EXIT_FAILURE);
    }
    OffsetStackNode* temp = stack->top;
    int poppedOffset = temp->offset;
    stack->top = stack->top->next;
    // free(temp);
    return poppedOffset;
}

// Function to get the top offset without popping
int peekOffset(OffsetStack* stack) {
    if (isOffsetStackEmpty(stack)) {
        printf("Stack is empty\n");
        exit(EXIT_FAILURE);
    }
    return stack->top->offset;
}

// Function to free the entire stack
void freeOffsetStack(OffsetStack* stack) {
    while (!isOffsetStackEmpty(stack)) {
        popOffset(stack);
    }
    free(stack);
}

struct node {
    char value[100]; // typecasting
    char type[1000]; 
    bool postfix; // for postfix expressions
    List* trueList;
    List* falseList;
    List* nextList;
};

struct list {
    int addr;
    List* next;
};

char* gen_label() {
    char* label = (char*)malloc(sizeof(char) * 100);
    if (label == NULL) {
        perror("Memory allocation failed");
        exit(EXIT_FAILURE);
    }
    sprintf(label, "t%d", labels);
    labels++;
    return label;
}

Node* createNode(char* value, char* type, List* trueList, List* falseList, List* nextList){
    Node* n = (Node*)malloc(sizeof(Node));
    strcpy(n->value, value);
    strcpy(n->type, type);
    n->postfix = false;
    n->nextList = nextList;
    n->trueList = trueList;
    n->falseList = falseList;
    return n;
}

List* makelist(int addr){
    List* list = (List*)malloc(sizeof(List));
    list->addr = addr;
    list->next = NULL;
}

List* merge(List* l1, List* l2) {
    if(l1 == NULL && l2 == NULL) return NULL;
    if (l1 == NULL) return l2;
    if (l2 == NULL) return l1;

    List* curr = l1;
    while (curr->next != NULL) {
        curr = curr->next;
    }
    curr->next = l2;
    // printList(l1, "merged l1 and l2");
    return l1;
}

void backpatch(List* list, int addr){
    // if(list == 0x21) return;
    List* curr = list;
    while(curr != NULL){
        sprintf(intermediate_code[curr->addr] + strlen(intermediate_code[curr->addr]),"%d\n",addr);
        curr = curr->next;
    }
}

void printList(List* list, const char* label) {
    printf("%s: ", label);
    List* curr = list;
    while (curr != NULL) {
        printf("%d -> ", curr->addr);
        curr = curr->next;
    }
    printf("NULL\n");
}

Type* dummy;

SymbolTable* currSymTable;
ScopeStack* scopeStack;
OffsetStack* offsetStack;
int offset = 0;

SymbolTable* symbolTableArray[1000];  // Array to hold up to 1000 symbol table addresses
int symbolTableCount = 0;

int compareOffsets(const void* a, const void* b) {
    HashNode* nodeA = (HashNode*)a;
    HashNode* nodeB = (HashNode*)b;
    return nodeA->offset - nodeB->offset;
}

#define TYPE_WIDTH 27  // Width for the Type column

void printSymbolTables() {
    for (int i = 0; i < symbolTableCount; i++) {
        SymbolTable* table = symbolTableArray[i];

        // Header for the current symbol table
        printf("\n+--------------------------------------------------------------+\n");
        printf("|                        Symbol Table %2d                       |\n", i + 1);
        printf("+----------------+-----------------------------+---------------+\n");
        printf("|      Name      |            Type             | Offset (Hex)  |\n");
        printf("+----------------+-----------------------------+---------------+\n");

        // Step 1: Collect all entries in an array for sorting
        HashNode* entries[100];  // Adjust size as needed
        int count = 0;

        for (int j = 0; j < TABLE_SIZE; j++) {
            HashNode* current = table->table[j];
            while (current != NULL) {
                entries[count++] = current;
                current = current->next;
            }
        }

        // Step 2: Sort entries by offset
        qsort(entries, count, sizeof(HashNode*), compareOffsets);

        // Step 3: Print sorted entries
        if (count == 0) {
            if (i == 0) {
                printf("|        Nothing to store in global scope                      |\n");
            } else {
                printf("|        Nothing to store in this scope                        |\n");
            }
        } else {
            for (int k = 0; k < count; k++) {
                // Extract values
                char* name = entries[k]->name;
                char* type = entries[k]->type;
                int offset = entries[k]->offset & 0xFFFF;

                // Handle wrapping for the Type column
                char buffer[TYPE_WIDTH + 1];
                int typeLen = strlen(type);
                int remaining = typeLen;

                // Print the first line with the Name and Offset
                strncpy(buffer, type, TYPE_WIDTH);
                buffer[TYPE_WIDTH] = '\0';
                printf("| %-14s | %-27s |     0x%04x    |\n", name, buffer, offset);
                remaining -= TYPE_WIDTH;

                // Print subsequent lines for wrapped content
                while (remaining > 0) {
                    type += TYPE_WIDTH;
                    strncpy(buffer, type, TYPE_WIDTH);
                    buffer[TYPE_WIDTH] = '\0';
                    printf("| %-14s | %-27s |                |\n", "", buffer);
                    remaining -= TYPE_WIDTH;
                }
            }
        }

        // Footer for the current table
        printf("+----------------+-----------------------------+---------------+\n\n");
    }
}



HashNode* findSymbol(const char* name) {
    for (int i = symbolTableCount; i >= 0; i--) {
        HashNode* symbol = lookupSymbol(symbolTableArray[i], name);
        if (symbol != NULL) {
            return symbol;  // Symbol found in this table
        }
    }
    return NULL;  // Symbol not found in any table
}

char* max(char* t1, char* t2) {
    // Handling "int" and "float" types
    char* type = (char*)malloc(sizeof(char) * 1000);
    if (strcmp(t1, "float") == 0 || strcmp(t2, "float") == 0) {
        sprintf(type, "%s", "float");
        return type;
    }
    sprintf(type, "%s", "int");
    return type;
}

char* widen(char* var, char* t, char* w){
    if(strcmp(t,w) == 0) return var;
    else if(strcmp(t, "int") == 0 && strcmp(w, "float") == 0){
        char* temp = gen_label();
        sprintf(intermediate_code[idx++],"%s = (float) %s\n", temp, var);
        return temp;
    }
}

%}

%union {
    char* string;
    struct node* node;
    int instr;
    struct list* list;
    struct Type* type;
}

%token <string> INT FLOAT CHAR IF ELSE IDEN NUM PL MI ST DV MD EQ SC LP RP LB RB LS RS INC DEC PEQ MEQ SEQ DEQ GT LT GTE LTE NE EE NN AND OR T F WHILE CM
%type <node> expr term stmt stmt_list assign control
%type <string> ass op un auto
%type <type> prim comp
%type <instr> M N

%left OR
%left AND
%nonassoc NE EE
%nonassoc NN
%left GTE LTE GT LT
%left PL MI
%left ST DV MD
%nonassoc INC DEC
%nonassoc LP RP LB RB
%nonassoc ELSE

%%

program:
      O stmt_list {
        if(!error_flag){
            printf("--------------Symbol Tables-------------\n");
            printSymbolTables();
            backpatch($2->nextList,idx); // jump out of the program
            printf("\n-----Intermediate Code-----\n\n");
            for (int i = 0; i < idx; i++) {
                printf("%3d:\t%s", i, intermediate_code[i]);
                strcpy(intermediate_code[i], "");
            }
            printf("\n");
        }
    }
    ;

stmt_list:
      stmt_list M stmt {
        if(!error_flag){
            // printList($1->nextList, "$1->nextList before backpatch");
            backpatch($1->nextList,$2);
            Node* temp = createNode("","",NULL,NULL,$3->nextList);
            $$ = temp;
        }
    }
    | stmt { 
        if(!error_flag){
            Node* temp = createNode("","",NULL,NULL,$1->nextList);
            $$ = temp;
        } 
    }
    ;

stmt:
      assign SC { if(!error_flag) $$ = $1; }
    | control { if(!error_flag) $$ = $1; }
    | declare SC { 
        if(!error_flag){
            Node* temp = createNode("","",NULL,NULL,NULL);
            $$ = temp;
        }
    }
    | LB P stmt_list RB { 
        if(!error_flag){
            // printList($2->nextList, "$2->nextList");
            // check this out
            currSymTable = popScope(scopeStack);
            offset = popOffset(offsetStack);
            Node* temp = createNode("","",NULL,NULL,$3->nextList);
            $$ = temp;
        } 
    }
    | LB RB { 
        if(!error_flag){
            Node* temp = createNode("","",NULL,NULL,NULL);
            $$ = temp;
        }
    }
    | expr SC { // fing SC
        if(!error_flag) $$ = $1;
    }
    | error {
        if(!error_flag){
            printf("Rejected - invalid expression\n");
            error_flag = 1;
            yyerrok;
        }
    }
    ;

declare:
      prim list comp { // fails for int a, b[2][3]; 
        if(!error_flag){
            // for each var in var_list inertSymbol(currSymTable, var, T.type, offset) & offset += T.width
            for(int i = 0; i < var_count; i++){
                // printf("%s ",var_list[i]);
                if(insertSymbol(currSymTable,var_list[i],$3->type,offset) == 1){
                    printf("Rejected - redeclaration of variable: %s in scope %d\n",var_list[i],symbolTableCount);
                    error_flag = 1;
                } else if(insertSymbol(currSymTable,var_list[i],$3->type,offset) == 2){
                    printf("Rejected - conflicting types for variable: %s in scope %d\n",var_list[i],symbolTableCount);
                    error_flag = 1;
                }
                offset += $3->width;
                strcpy(var_list[i], "");
            }
            // printf("\n");
            var_count = 0;
            dummy = createType("",-1);
        }
    }
    ;

list:
      list CM IDEN { if(!error_flag) sprintf(var_list[var_count++],"%s",$3); }
    | list CM IDEN EQ expr { 
        if(!error_flag) {
            sprintf(var_list[var_count++],"%s",$3);
            char* t = gen_label();
            if(strcmp(dummy->type,$5->type) != 0){
                sprintf(intermediate_code[idx++],"%s = (%s) %s\n", t, dummy->type, $5);
            }else{
                sprintf(intermediate_code[idx++],"%s = %s\n", t, $5);
            }
            sprintf(intermediate_code[idx++],"%s = %s\n", $3, t);
        }    
    }
    | IDEN EQ expr { 
        if(!error_flag) {
            sprintf(var_list[var_count++],"%s",$1); 
            char* t = gen_label();
            if(strcmp(dummy->type,$3->type) != 0){
                sprintf(intermediate_code[idx++],"%s = (%s) %s\n", t, dummy->type, $3);
            }else{
                sprintf(intermediate_code[idx++],"%s = %s\n", t, $3);
            }
            sprintf(intermediate_code[idx++],"%s = %s\n", $1, t);
        }
    }
    | IDEN { if(!error_flag) sprintf(var_list[var_count++],"%s",$1); }
    ;

prim:
      INT { if(!error_flag) dummy = $$ = createType($1,4); }
    | FLOAT { if(!error_flag) dummy = $$ = createType($1,4); }
    | CHAR { if(!error_flag) dummy = $$ = createType($1,1); }
    ;

comp:
      LS NUM RS comp {
        if(!error_flag) {
            int num = atoi($2);
            int width = num*$4->width;
            char value[1000]; sprintf(value,"array(%d,%s)",num,$4->type);
            $$ = createType(value,width);
        }
    }
    | { if(!error_flag) $$ = createType(dummy->type,dummy->width); }
    ;

assign:
      expr ass expr { 
        // printf("postfix: %b\n",$1->postfix);
        if(!error_flag) {
            if($1->postfix){
                printf("Rejected - cannot assign to a postfix expression\n");
                error_flag = 1;
            } else {
                char* endptr; strtod($1->value,&endptr);
                if(*endptr == '\0'){
                    printf("Rejected - cannot assign to a constant value\n");
                    error_flag = 1;
                }
                char* t = gen_label();
                if(strcmp($1->type,$3->type) != 0){
                    sprintf(intermediate_code[idx++],"%s = (%s) %s\n", t, $1->type, $3);
                }
                char* op = $2;
                if (strlen($2) > 1) {
                    char* temp = gen_label();
                    sprintf(intermediate_code[idx++], "%s = %s %c %s\n", temp, $1, op[0], t);
                    sprintf(intermediate_code[idx++], "%s = %s\n", $1, temp);
                }
                else sprintf(intermediate_code[idx++], "%s = %s\n", $1, t);
                Node* _temp = createNode("","",NULL,NULL,NULL);
                $$ = _temp;
            }
        }
    }
    ;

control:
      IF LP expr RP M stmt ELSE N M stmt { 
        if(!error_flag){
            backpatch($3->trueList,$5);
            backpatch($3->falseList,$9);
            // printf("\nN: %d\n",$8);
            // Node* _temp = createNode("","",NULL,NULL,merge($6->nextList,makelist($8)));
            // printList(merge($6->nextList,list),"Merged List-1");
            List* _temp = merge($6->nextList,makelist($8));
            Node* temp = createNode("","",NULL,NULL,merge(_temp,$10->nextList));
            // printList(merge(_temp,$10->nextList),"Merged List-2");
            $$ = temp;
        }
    }
    | IF LP expr RP M stmt {
        if(!error_flag){
            backpatch($3->trueList,$5);
            Node* temp = createNode("","",NULL,NULL,merge($3->falseList,$6->nextList));
            $$ = temp;
        }
    }
    | WHILE M LP expr RP M stmt {
        if(!error_flag){
            backpatch($7->nextList,$2);
            backpatch($4->trueList,$6);
            Node* temp = createNode("","",NULL,NULL,$4->falseList);
            $$ = temp;
            sprintf(intermediate_code[idx++], "goto %d\n",$2);
        }
    }
    | IF LP RP {
        if(!error_flag){
            printf("Rejected - empty bool expr inside if\n");
            error_flag = 1;
        }
    }
    ;

expr:
      expr PL expr {
        if (!error_flag) {
            char* t = max($1->type,$3->type);
            char* a1 = widen($1->value,$1->type,t);
            char* a2 = widen($3->value,$3->type,t);
            char* label = gen_label();
            // $1 is node though; getting typecasted; better use $1->value;
            sprintf(intermediate_code[idx++], "%s = %s %s %s\n", label, a1, "+", a2); 
            $$ = createNode(label, t, NULL, NULL, NULL);
        }
    }
    | expr MI expr {
        if (!error_flag) {
            char* t = max($1->type,$3->type);
            char* a1 = widen($1->value,$1->type,t);
            char* a2 = widen($3->value,$3->type,t);
            char* label = gen_label();
            // $1 is node though; getting typecasted; better use $1->value;
            sprintf(intermediate_code[idx++], "%s = %s %s %s\n", label, a1, "-", a2); 
            $$ = createNode(label, t, NULL, NULL, NULL);
        }
    }
    | expr ST expr {
        if (!error_flag) {
            char* t = max($1->type,$3->type);
            char* a1 = widen($1->value,$1->type,t);
            char* a2 = widen($3->value,$3->type,t);
            char* label = gen_label();
            // $1 is node though; getting typecasted; better use $1->value;
            sprintf(intermediate_code[idx++], "%s = %s %s %s\n", label, a1, "*", a2); 
            $$ = createNode(label, t, NULL, NULL, NULL);
        }
    }
    | expr DV expr {
        if (!error_flag) {
            char* t = max($1->type,$3->type);
            char* a1 = widen($1->value,$1->type,t);
            char* a2 = widen($3->value,$3->type,t);
            char* label = gen_label();
            // $1 is node though; getting typecasted; better use $1->value;
            sprintf(intermediate_code[idx++], "%s = %s %s %s\n", label, a1, "/", a2); 
            $$ = createNode(label, t, NULL, NULL, NULL);
        }
    }
    | expr MD expr {
        if (!error_flag) {
            char* t = max($1->type,$3->type);
            char* a1 = widen($1->value,$1->type,t);
            char* a2 = widen($3->value,$3->type,t);
            char* label = gen_label();
            // $1 is node though; getting typecasted; better use $1->value;
            sprintf(intermediate_code[idx++], "%s = %s %s %s\n", label, a1, "%", a2); 
            $$ = createNode(label, t, NULL, NULL, NULL);
        }
    }
    | expr GTE expr {
        // B
        if (!error_flag) {
            Node* temp = createNode("","",makelist(idx),makelist(idx+1),NULL);
            sprintf(intermediate_code[idx++], "if %s %s %s goto ", $1, ">=", $3);
            sprintf(intermediate_code[idx++], "goto ");
            $$ = temp;
        }
    }
    | expr LTE expr {
        if (!error_flag) {
            Node* temp = createNode("","",makelist(idx),makelist(idx+1),NULL);
            sprintf(intermediate_code[idx++], "if %s %s %s goto ", $1, "<=", $3);
            sprintf(intermediate_code[idx++], "goto ");
            $$ = temp;
        }
    }
    | expr GT expr {
        if (!error_flag) {
            Node* temp = createNode("","",makelist(idx),makelist(idx+1),NULL);
            sprintf(intermediate_code[idx++], "if %s %s %s goto ", $1, ">", $3);
            sprintf(intermediate_code[idx++], "goto ");
            $$ = temp;
        }
    }
    | expr LT expr {
        if (!error_flag) {
            Node* temp = createNode("","",makelist(idx),makelist(idx+1),NULL);
            sprintf(intermediate_code[idx++], "if %s %s %s goto ", $1, "<", $3);
            sprintf(intermediate_code[idx++], "goto ");
            $$ = temp;
        }
    }
    | expr NE expr {
        if (!error_flag) {
            Node* temp = createNode("","",makelist(idx),makelist(idx+1),NULL);
            sprintf(intermediate_code[idx++], "if %s %s %s goto ", $1, "!=", $3);
            sprintf(intermediate_code[idx++], "goto ");
            $$ = temp;
        }
    }
    | expr EE expr {
        if (!error_flag) {
            Node* temp = createNode("","",makelist(idx),makelist(idx+1),NULL);
            sprintf(intermediate_code[idx++], "if %s %s %s goto ", $1, "==", $3);
            sprintf(intermediate_code[idx++], "goto ");
            $$ = temp;
        }
    }
    | expr AND M expr {
        if (!error_flag) {
            Node* temp = createNode("","",$4->trueList,merge($1->falseList,$4->falseList),NULL);
            backpatch($1->trueList,$3);
            $$ = temp;
        }
    }
    | expr OR M expr {
        if (!error_flag) {
            Node* temp = createNode("","",merge($1->trueList,$4->trueList),$4->falseList,NULL);
            backpatch($1->falseList,$3);
            $$ = temp;
        }
    }
    | NN expr {
        if(!error_flag){
            Node* temp = createNode("","",$2->falseList,$2->trueList,NULL);
            $$ = temp;
        }
    }
    | T {   if(!error_flag){
                Node* temp = createNode("","",makelist(idx),NULL,NULL);
                //printList(temp, "True temp");
                sprintf(intermediate_code[idx++], "goto ");
                $$ = temp;
            }
        }
    | F {   if(!error_flag){
                Node* temp = createNode("","",NULL,makelist(idx),NULL);
                sprintf(intermediate_code[idx++], "goto ");
                $$ = temp;
            }
        }
    | expr op {
        if(!error_flag){
            error_flag = 1;
            printf("Rejected - operand missing\n");
        }
    }
    | LP expr RP {
        if(!error_flag){
            Node* temp = createNode($2->value,$2->type,$2->trueList,$2->falseList,NULL);
            $$ = temp;
        }
    }
    | LP expr error {
        if(!error_flag){
            error_flag = 1;
            yyerrok;
            printf("Rejected - closing parenthesis missing\n");
        }
    }
    | term {
        if(!error_flag) $$ = $1;
    }
    ;

M:  { if(!error_flag) $$ = idx; };
N:  { if(!error_flag) $$ = idx; sprintf(intermediate_code[idx++], "goto "); };
O:  {
        if(!error_flag){
            // init a scope stack and an offset stack 
            scopeStack = createScopeStack();
            offsetStack = createOffsetStack();
            // init the offset and a symbol table for global variables
            offset = 0; currSymTable = createSymbolTable();
            symbolTableArray[symbolTableCount++] = currSymTable;
        }
    };
P:  {
        if(!error_flag){
            // scope variables
            pushScope(scopeStack, currSymTable);
            currSymTable = createSymbolTable();
            pushOffset(offsetStack, offset);
            offset = 0;
            symbolTableArray[symbolTableCount++] = currSymTable;
        }
    };
term:
      un auto IDEN ERR {
        if (!error_flag) {
            HashNode* symbol = findSymbol($3);
            if(symbol == NULL) {
                printf("variable '%s' is not declared in the scope: %d\n",$3,symbolTableCount);
                error_flag = 1;
            }
            if (strcmp($1, "-")) {
                char* label = gen_label();
                char* op = $2;
                sprintf(intermediate_code[idx++], "%s = %s %c 1\n", label, $3, op[0]);
                sprintf(intermediate_code[idx++], "%s = %s\n", $3, label);
                Node* _temp = createNode(label,symbol->type,NULL,NULL,NULL);
                $$ = _temp;
            } else {
                if (strcmp($2, "--") == 0) {
                    error_flag = 1;
                    printf("Rejected - not assignable\n");
                } else {
                    printf("helllllooooo\n");
                    char* label = gen_label();
                    char* temp = gen_label();
                    sprintf(intermediate_code[idx++], "%s = %s + 1\n", temp, $3);
                    sprintf(intermediate_code[idx++], "%s = -%s\n", label, temp);
                    sprintf(intermediate_code[idx++], "%s = %s\n", $3, temp);
                    Node* _temp = createNode(label,symbol->type,NULL,NULL,NULL);
                    $$ = _temp;
                }
            }
            $$->postfix = true;
        }
    }
    | un IDEN auto ERR {
        if (!error_flag) {
            HashNode* symbol = findSymbol($2);
            if(symbol == NULL) {
                printf("variable '%s' is not declared in the scope: %d\n",$2,symbolTableCount);
                error_flag = 1;
            }
            char* label = gen_label();
            char* temp = gen_label();
            char* op = $3;
            sprintf(intermediate_code[idx++], "%s = %s\n", temp, $2);
            sprintf(intermediate_code[idx++], "%s = %s%s\n", label, $1, temp);
            sprintf(intermediate_code[idx++], "%s = %s %c 1\n", $2, temp, op[0]);
            Node* _temp = createNode(label,symbol->type,NULL,NULL,NULL);
            $$ = _temp;
            $$->postfix = true;
            // printf("postfix: %b\n",$$->postfix);
        } 
    }
    | un IDEN ERR_ {
        if (!error_flag) {
            HashNode* symbol = findSymbol($2);
            if(symbol == NULL) {
                printf("variable '%s' is not declared in the scope: %d\n",$2,symbolTableCount);
                error_flag = 1;
            } else {
                if (!strcmp($1, "-")) {
                    char* label = gen_label();
                    char* temp = gen_label();
                    sprintf(intermediate_code[idx++], "%s = -%s\n", temp, $2);
                    sprintf(intermediate_code[idx++], "%s = %s\n", label, temp);
                    Node* _temp = createNode(label,symbol->type,NULL,NULL,NULL);
                    $$ = _temp;
                } else {
                    Node* temp = createNode($2,symbol->type,NULL,NULL,NULL);
                    $$ = temp;
                }
            }
        }
    }
    | un NUM ERR_ {
        if (!error_flag) {
            if (!strcmp($1, "-")) {
                char* label = gen_label();
                sprintf(intermediate_code[idx++], "%s = -%s\n", label, $2);
                Node* temp = createNode(label,"",NULL,NULL,NULL);
                $$ = temp;
            } else {
                Node* temp = createNode($2,"",NULL,NULL,NULL);
                $$ = temp;
            }
        }
    }
    | un INC NUM {
        error_flag = 1;
        printf("Rejected - cannot pre-increment a constant value\n");
    }
    | un DEC NUM {
        error_flag = 1;
        printf("Rejected - cannot pre-decrement a constant value\n");
    }
    | un NUM INC {
        error_flag = 1;
        printf("Rejected - cannot post-increment a constant value\n");
    }
    | un NUM DEC {
        error_flag = 1;
        printf("Rejected - cannot post-decrement a constant value\n");
    }
    ;

ERR:
      auto {
        error_flag = 1;
        printf("Rejected - not assignable\n");
    }
    | IDEN {
        error_flag = 1;
        printf("Rejected - operator missing\n");
    }
    | NUM {
        error_flag = 1;
        printf("Rejected - operator missing\n");
    }
    | { }
    ;

ERR_:
      IDEN {
        error_flag = 1;
        printf("Rejected - operator missing\n");
    }
    | NUM {
        error_flag = 1;
        printf("Rejected - operator missing\n");
    }
    | { }
    ;

ass:
      EQ { $$ = strdup($1); }
    | PEQ { $$ = strdup($1); }
    | MEQ { $$ = strdup($1); }
    | SEQ { $$ = strdup($1); }
    | DEQ { $$ = strdup($1); }
    ;

op:
      PL { $$ = strdup($1); }
    | MI { $$ = strdup($1); }
    | ST { $$ = strdup($1); }
    | DV { $$ = strdup($1); }
    | MD { $$ = strdup($1); }
    ;

auto:
      INC { $$ = strdup($1); }
    | DEC { $$ = strdup($1); }
    ;

un:
      MI { $$ = strdup($1); }
    | { $$ = strdup(""); }
    ;

%%

void yyerror(const char *s) {
    // fprintf(stderr, "%s\n", s);
}

int main(int argc, char** argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    FILE *input_file = fopen(argv[1], "r");
    if (input_file == NULL) {
        perror("Error opening file");
        return EXIT_FAILURE;
    }

    yyin = input_file;

    yyparse();

    fclose(input_file);

    return EXIT_SUCCESS;
}
