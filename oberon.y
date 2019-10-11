%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char* s);

    struct Node {
        char* data;
        int index;
        struct Node** children;
    };

    struct Node* createNode(const char* data, struct Node** children, int len);
    void insertChild(struct Node* parent, struct Node* child);

    struct Node* root;
%}

%union {
    char* string;
    struct Node* node;
}

%token <string> IDENTIFIER
%token <string> PREDEFINED_IDENTIFIER

%token K_MODULE K_ARRAY K_BEGIN K_BY K_CASE K_CONST K_DIV K_DO K_ELSE K_ELSIF
%token K_END K_EXIT K_FOR K_IF K_IMPORT K_IN K_IS K_LOOP K_MOD K_NIL
%token K_OF K_OR K_POINTER K_PROCEDURE K_RECORD K_REPEAT K_RETURN K_THEN
%token K_TO K_TYPE K_UNTIL K_VAR K_WHILE K_WITH K_TRUE K_FALSE

%token T_INTEGER T_REAL T_STRING

%token O_ADD O_SUB O_MUL O_DIV O_NOT O_AND D_DOT D_COM D_COL D_SEM
%token D_PIP D_LBR D_RBR D_LSQBR D_RSQBR D_LCURBR D_RCURBR D_DDOT O_GT
%token O_GTE O_LT O_LTE O_NOTEQ O_EQ O_POINT O_ASS   

%type <node> CompilationUnit

%start CompilationUnit

%%

CompilationUnit
    : ModuleList { struct Node** children; root = createNode("root", children, 0); }
    ;
    
ModuleList
    : Module ModuleList { }
    | /* empty */
    ;
    
Module
    : K_MODULE Identifier D_SEM ModuleDeclaration { printf("CompilationUnit\n"); }
    ;

ModuleDeclaration
    : ImportList DeclarationSequence ModuleBody K_END Identifier D_DOT { printf("Inside ModuleDeclaration\n"); }
    ;

ImportList
    : K_IMPORT ImportEntries D_SEM { printf("Inside ImportList\n"); }
    | /* empty */
    ;

ImportEntries
    : ImportEntry
    | ImportEntries D_COM ImportEntry { printf("Inside ImportEntries\n"); }
    ;

ImportEntry
    : Identifier { printf("Inside ImportEntry\n"); }
    | Identifier O_ASS Identifier
    ;

DeclarationSequence
    : ConstBlock TypeBlock VarBlock ProcedureSequence { printf("Inside DeclarationSequence\n"); }
    ;

ConstBlock
    : K_CONST ConstSequence { printf("Inside ConstBlock\n"); }
    | /* empty */
    ;

ConstSequence
    : ConstDeclaration D_SEM ConstSequence { printf("Inside ConstSequence\n"); }
    | /* empty */
    ;

ConstDeclaration
    : Identifier O_EQ ConstExpression { printf("Inside ConstDeclaration\n"); }
    ;

ConstExpression
    : Expression { printf("Inside ConstExpression\n"); }
    ;

TypeBlock
    : K_TYPE TypeSequence { printf("Inside TypeBlock\n"); }
    | /* empty */
    ;

TypeSequence
    : TypeDeclaration D_SEM TypeSequence { printf("Inside TypeSequence\n"); }
    | /* empty */
    ;

TypeDeclaration
    : IdentDef O_EQ Type { printf("Inside TypeDeclaration\n"); }
    ;

VarBlock
    : K_VAR VarSequence { printf("Inside VarBlock\n"); }
    | /* empty */
    ;

VarSequence
    : VarDeclaration D_SEM VarSequence { printf("Inside VarSequence\n"); }
    | /* empty */
    ;

VarDeclaration
    : IdentDefList D_COL Type { printf("Inside VarDeclaration\n"); }
    ;

ProcedureSequence
    : ProcedureDeclaration D_SEM ProcedureSequence { printf("Inside ProcedureSequence\n"); }
    | /* empty */
    ;

ProcedureDeclaration
    : ProcedureHeading D_SEM ProcedureBody Identifier { printf("Inside ProcedureDeclaration\n"); }
    ;

ProcedureHeading
    : K_PROCEDURE IdentDef { printf("Inside ProcedureHeading\n"); }
    | K_PROCEDURE IdentDef FormalParameters
    ;

ProcedureBody
    : DeclarationSequence ProcedureBegin ProcedureReturn K_END { printf("Inside ProcedureBody\n"); }
    ;

ProcedureBegin
    : K_BEGIN StatementList { printf("Inside ProcedureBegin\n"); }
    | /* empty */
    ;

ProcedureReturn
    : K_RETURN Expression { printf("Inside ProcedureReturn\n"); }
    | /* empty */
    ;

StatementList
    : Statement { printf("Inside StatementList(solo)\n"); }
    | StatementList D_SEM Statement { printf("Inside StatementList\n"); }
    ;

Statement
    : Assignment { printf("Inside Statement(Assignment)\n"); }
    | ProcedureCall { printf("Inside Statement(ProcedureCall)\n"); }
    | IfStatement { printf("Inside Statement(IfStatement)\n"); }
    | CaseStatement { printf("Inside Statement(CaseStatement)\n"); }
    | WhileStatement { printf("Inside Statement(WhileStatement)\n"); }
    | RepeatStatement { printf("Inside Statement(RepeatStatement)\n"); }
    | ForStatement { printf("Inside Statement(ForStatement)\n"); }
    | /* empty */
    ;

Assignment
    : Designator O_ASS Expression { printf("Inside Assignment\n"); }
    ;

ProcedureCall
    : Designator ActualParameter
    ;

IfStatement
    : K_IF Expression K_THEN StatementList ElseIfSequence ElseStatement K_END { printf("Inside IfStatement\n"); }
    ;

ElseIfSequence
    : K_ELSIF Expression K_THEN StatementList ElseIfSequence { printf("Inside ElseIfSequence\n"); }
    | /* empty */
    ;

ElseStatement
    : K_ELSE StatementList { printf("Inside ElseStatement\n"); }
    | /* empty */
    ;

CaseStatement
    : K_CASE Expression K_OF Case CaseSequence K_END { printf("Inside CaseStatement\n"); }
    ;

CaseSequence
    : D_PIP Case CaseSequence { printf("Inside CaseSequence\n"); }
    | /* empty */
    ;

Case
    : CaseLabelList D_COL StatementList { printf("Inside Case\n"); }
    | /* empty */
    ;

CaseLabelList
    : LabelRange { printf("Inside CaseLabelList\n"); }
    | CaseLabelList D_COM LabelRange
    ;

LabelRange
    : Label { printf("Inside LabelRange\n"); }
    | Label D_DDOT Label
    ;

Label
    : T_INTEGER | T_STRING | Qualident
    ;

WhileStatement
    : K_WHILE Expression K_DO StatementList WhileElseifStatement K_END { printf("Inside WhileStatement\n"); }
    ;

WhileElseifStatement
    : K_ELSIF Expression K_DO StatementList WhileElseifStatement { printf("Inside WhileElseifStatement\n"); }
    | /* empty */
    ;

RepeatStatement
    : K_REPEAT StatementList K_UNTIL Expression { printf("Inside RepeatStatement\n"); }
    ;

ForStatement
    : K_FOR Identifier O_ASS Expression K_TO Expression ByStatement K_DO StatementList K_END { printf("Inside ForStatement\n"); }
    ;

ByStatement
    : K_BY ConstExpression { printf("Inside ByStatement\n"); }
    | /* empty */
    ;

ModuleBody
    : K_BEGIN StatementList { printf("Inside ModuleBody\n"); }
    | /* empty */
    ;

Expression
    : SimpleExpression
    | SimpleExpression Relation SimpleExpression
    ;

Relation
    : O_EQ | O_NOTEQ | O_LT | O_LTE | O_GT | O_GTE | K_IN | K_IS
    ;

SimpleExpression
    : PlusMinus Term AddSequence { printf("Inside SimpleExpression\n"); }
    ;

PlusMinus
    : O_ADD | O_SUB
    | /* empty */
    ;

AddSequence
    : AddOperator Term AddSequence { printf("Inside AddSequence\n"); }
    | /* empty */
    ;

AddOperator
    : O_ADD | O_SUB | K_OR
    ;

Term
    : Factor { printf("Inside Term\n"); }
    | Term MulOperator Factor
    ;

MulOperator
    : O_MUL | O_DIV | K_DIV | K_MOD | O_AND
    ;

Factor
    : Number | T_STRING | K_NIL | K_TRUE | K_FALSE
    | Set | Designator ActualParameter
    | D_LBR Expression D_RBR | O_NOT Factor
    ;

Number
    : T_INTEGER | T_REAL
    ;

Set
    : D_LCURBR D_RCURBR
    | D_LCURBR Elements D_RCURBR
    ;

Elements
    : Element
    | Elements D_COM Element { printf("Inside Elements\n"); }
    ;

Element
    : Expression
    | Expression D_DDOT Expression
    ;

Designator
    : Qualident SelectorSequence { printf("Inside designator\n"); }
    ;

SelectorSequence
    : Selector SelectorSequence { printf("Inside SelectorSequence\n"); }
    | /* empty */
    ;

Selector
    : D_DOT Identifier
    | D_LSQBR ExpList D_RSQBR
    | O_POINT
    ;

ActualParameter
    : D_LBR D_RBR
    | D_LBR ExpList D_RBR
    | /* empty */
    ;

ExpList
    : Expression { printf("Inside ExpList(solo)\n"); }
    | ExpList D_COM Expression
    ;

Type
    : Qualident | ArrayType | RecordType | PointerType | ProcedureType
    ;

ArrayType
    : K_ARRAY LengthList K_OF Type
    ;

Length
    : ConstExpression { printf("Inside Length\n"); }
    ;

LengthList
    : Length
    | LengthList D_COM Length { printf("Inside LengthList\n"); }
    ;

RecordType
    : K_RECORD RecordInheritance RecordFields K_END { printf("Inside RecordType\n"); }
    ;

RecordInheritance
    : D_LBR BaseType D_RBR { printf("Inside RecordInheritance\n"); }
    | /* empty */
    ;

RecordFields
    : FieldListSequence { printf("Inside RecordFields\n"); }
    | /* empty */
    ;

BaseType
    : Qualident { printf("Inside BaseType\n"); }
    ;

FieldListSequence
    : FieldList { printf("Inside FieldListSequend\n"); }
    | FieldListSequence D_SEM FieldList
    ;

FieldList
    : IdentDefList D_COL Type { printf("Inside FieldList\n"); }
    ;

PointerType
    : K_POINTER K_TO Type { printf("Inside PointerType\n"); }
    ;

ProcedureType
    : K_PROCEDURE
    | K_PROCEDURE FormalParameters
    ;

FormalParameters
    : D_LBR FormalArguments D_RBR FormalResult { printf("Inside FormalParameters\n"); }
    | D_LBR D_RBR FormalResult { printf("Inside FormalParameters\n"); }
    ;

FormalArguments
    : FormalParametersSection { printf("Inside FormalArguments\n"); }
    | FormalArguments D_SEM FormalParametersSection { printf("Inside FormalArguments\n"); }
    ;

FormalResult
    : D_COL Qualident { printf("Inside FormalResult\n"); }
    | /* empty */
    ;

FormalParametersSection
    : IdentList D_COL FormalType
    | K_VAR IdentList D_COL FormalType
    ;

IdentList
    : Identifier
    | IdentList D_COM Identifier { printf("Inside IdentList\n"); }
    ;

FormalType
    : FormalTypeSequence Qualident { printf("Inside FormalType\n"); }
    ;

FormalTypeSequence
    : K_ARRAY K_OF FormalTypeSequence { printf("Inside FormalTypeSequence\n"); }
    | /* empty */
    ;

Qualident
    : Identifier { printf("Inside Qualident\n"); }
    | Identifier D_DOT Identifier { printf("Inside Qualident\n"); }
    ;

IdentDefList
    : IdentDef { printf("Inside IdentDefList\n"); }
    | IdentDefList D_COM IdentDef
    ;

IdentDef
    : Identifier
    | Identifier O_MUL
    ;

Identifier
    : IDENTIFIER { printf("Identifier %s\n", $1); }
    | PREDEFINED_IDENTIFIER { printf("Pre identifier %s\n", $1); }
    ;

%%

struct Node* createNode(const char* data, struct Node** children, int len) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));

    newNode->data = (char*)malloc((strlen(data) + 1) * sizeof(char));
    strcpy(newNode->data, data);

    newNode->index = 0;

    newNode->children = (struct Node**)malloc(len * sizeof(struct Node*));
    for (int i = 0; i < len; i++) {
        insertChild(newNode, children[i]);
    }

    return newNode;
}

void insertChild(struct Node* parent, struct Node* child) {
    parent->children[parent->index++] = child;
}

int main(int argc, char** argv) {
    #ifdef YYDEBUG
        yydebug = 0;
    #endif

    if (argc != 2) {
        fprintf(stderr, "Usage: %s source\n", argv[0]);
        exit(1);
    }

    yyin = fopen(argv[1], "r");

    yyparse();
    printf("Root children number %d\n", root->index);

    fclose(yyin);
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
