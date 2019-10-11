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

%type <node> Identifier IdentDef IdentDefList Qualident FormalTypeSequence FormalType 
%type <node> IdentList FormalParametersSection FormalResult FormalArguments FormalParameters 
%type <node> ProcedureType PointerType FieldList FieldListSequence BaseType RecordFields
%type <node> RecordInheritance RecordType LengthList Length ArrayType Type ExpList 
%type <node> ActualParameter Selector SelectorSequence Designator Element Elements Set Number
%type <node> Factor MulOperator Term AddOperator AddSequence PlusMinus SimpleExpression Relation
%type <node> Expression ModuleBody ByStatement ForStatement RepeatStatement WhileElseifStatement
%type <node> WhileStatement Label LabelRange CaseLabelList Case CaseSequence CaseStatement
%type <node> ElseStatement ElseIfSequence IfStatement ProcedureCall Assignment Statement
%type <node> StatementList ProcedureReturn ProcedureBegin ProcedureBody ProcedureHeading
%type <node> ProcedureDeclaration ProcedureSequence VarDeclaration VarSequence VarBlock
%type <node> TypeDeclaration TypeSequence TypeBlock ConstExpression ConstDeclaration
%type <node> ConstSequence ConstBlock DeclarationSequence ImportEntry ImportEntries
%type <node> ImportList ModuleDeclaration Module ModuleList CompilationUnit


%start CompilationUnit

%%

CompilationUnit
    : ModuleList { struct Node** children = {$1}; root = createNode("root", children, 1); }
    ;
    
ModuleList
    : Module ModuleList {struct Node** children = {$1, $2}; $$ = createNode("ModuleList", children, 2); }
    | /* empty */ { $$ = NULL;}
    ;
    
Module
    : K_MODULE Identifier D_SEM ModuleDeclaration { struct Node** children = {$2, $4}; $$ = createNode("Module", children, 2);  }
    ;

ModuleDeclaration
    : ImportList DeclarationSequence ModuleBody K_END Identifier D_DOT { struct Node** children = {$1, $2, $3, $5};
                                                                         $$ = createNode("ModuleDeclaration", children, 4); }
    ;

ImportList
    : K_IMPORT ImportEntries D_SEM { struct Node** children = {$2}; $$ = createNode("ImportList", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

ImportEntries
    : ImportEntry {struct Node** children = {$1}; $$ = createNode("ImportList", children, 1);}
    | ImportEntries D_COM ImportEntry { struct Node** children = {$1, $3}; $$ = createNode("ImportList", children, 2); }
    ;

ImportEntry
    : Identifier { struct Node** children = {$1}; $$ = createNode("ImportEntry", children, 1); }
    | Identifier O_ASS Identifier
    ;

DeclarationSequence
    : ConstBlock TypeBlock VarBlock ProcedureSequence { struct Node** children = {$1, $2, $3, $4}; 
                                        $$ = createNode("DeclarationSequence", children, 4); }
    ;

ConstBlock
    : K_CONST ConstSequence { struct Node** children = {$2}; $$ = createNode("ConstBlock", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

ConstSequence
    : ConstDeclaration D_SEM ConstSequence { struct Node** children = {$1, $3}; $$ = createNode("ConstSequence", children, 2); }
    | /* empty */ { $$ = NULL;}
    ;

ConstDeclaration
    : Identifier O_EQ ConstExpression { struct Node** children = {$1, $3}; $$ = createNode("ConstDeclaration", children, 2); }
    ;

ConstExpression
    : Expression { struct Node** children = {$1}; $$ = createNode("ConstExpression", children, 1); }
    ;

TypeBlock
    : K_TYPE TypeSequence { struct Node** children = {$2}; $$ = createNode("TypeBlock", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

TypeSequence
    : TypeDeclaration D_SEM TypeSequence { struct Node** children = {$1, $3}; $$ = createNode("TypeSequence", children, 2); }
    | /* empty */ { $$ = NULL;}
    ;

TypeDeclaration
    : IdentDef O_EQ Type { struct Node** children = {$1, $3}; $$ = createNode("TypeDeclaration", children, 2); }
    ;

VarBlock
    : K_VAR VarSequence { struct Node** children = {$2}; $$ = createNode("VarBlock", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

VarSequence
    : VarDeclaration D_SEM VarSequence { struct Node** children = {$1, $3}; $$ = createNode("VarSequence", children, 2); }
    | /* empty */ { $$ = NULL;}
    ;

VarDeclaration
    : IdentDefList D_COL Type { struct Node** children = {$1, $3}; $$ = createNode("VarDeclaration", children, 2); }
    ;

ProcedureSequence
    : ProcedureDeclaration D_SEM ProcedureSequence { struct Node** children = {$1, $3}; $$ = createNode("ProcedureSequence", children, 2); }
    | /* empty */ { $$ = NULL;}
    ;

ProcedureDeclaration
    : ProcedureHeading D_SEM ProcedureBody Identifier { struct Node** children = {$1, $3, $4};
                                             $$ = createNode("ProcedureDeclaration", children, 3); }
    ;

ProcedureHeading
    : K_PROCEDURE IdentDef { struct Node** children = {$2}; $$ = createNode("ProcedureHeading", children, 1); }
    | K_PROCEDURE IdentDef FormalParameters { struct Node** children = {$2, $3}; $$ = createNode("ProcedureDeclaration", children, 2); }
    ;

ProcedureBody
    : DeclarationSequence ProcedureBegin ProcedureReturn K_END { struct Node** children = {$1, $2, $3}; 
                                        $$ = createNode("ProcedureBody", children, 3); }
    ;

ProcedureBegin
    : K_BEGIN StatementList { struct Node** children = {$2}; $$ = createNode("ProcedureBegin", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

ProcedureReturn
    : K_RETURN Expression { struct Node** children = {$2}; $$ = createNode("ProcedureReturn", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

StatementList
    : Statement { struct Node** children = {$1}; $$ = createNode("StatementList", children, 1); }
    | StatementList D_SEM Statement { struct Node** children = {$1, $3}; $$ = createNode("StatementList", children, 2); }
    ;

Statement
    : Assignment { struct Node** children = {$1}; $$ = createNode("Statement", children, 1); }
    | ProcedureCall { struct Node** children = {$1}; $$ = createNode("Statement", children, 1); }
    | IfStatement { struct Node** children = {$1}; $$ = createNode("Statement", children, 1); }
    | CaseStatement { struct Node** children = {$1}; $$ = createNode("Statement", children, 1); }
    | WhileStatement { struct Node** children = {$1}; $$ = createNode("Statement", children, 1); }
    | RepeatStatement { struct Node** children = {$1}; $$ = createNode("Statement", children, 1); }
    | ForStatement { struct Node** children = {$1}; $$ = createNode("Statement", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

Assignment
    : Designator O_ASS Expression { struct Node** children = {$1, $3}; $$ = createNode("Assignment", children, 2); }
    ;

ProcedureCall
    : Designator ActualParameter { struct Node** children = {$1, $2}; $$ = createNode("ProcedureCall", children, 2); }
    ;

IfStatement
    : K_IF Expression K_THEN StatementList ElseIfSequence ElseStatement K_END { struct Node** children = {$2, $4, $5, $6}; 
                                                                    $$ = createNode("IfStatement", children, 4); }
    ;

ElseIfSequence
    : K_ELSIF Expression K_THEN StatementList ElseIfSequence { struct Node** children = {$2, $4, $5}; 
                                                                $$ = createNode("ElseIfSequence", children, 3); }
    | /* empty */ { $$ = NULL;}
    ;

ElseStatement
    : K_ELSE StatementList { struct Node** children = {$2}; $$ = createNode("ElseStatement", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

CaseStatement
    : K_CASE Expression K_OF Case CaseSequence K_END { struct Node** children = {$2, $4, $5}; $$ = createNode("CaseStatement", children, 3); }
    ;

CaseSequence
    : D_PIP Case CaseSequence { struct Node** children = {$2, $3}; $$ = createNode("CaseSequence", children, 2); }
    | /* empty */ { $$ = NULL;}
    ;

Case
    : CaseLabelList D_COL StatementList { struct Node** children = {$1, $3}; $$ = createNode("Case", children, 2); }
    | /* empty */ { $$ = NULL;}
    ;

CaseLabelList
    : LabelRange { struct Node** children = {$1}; $$ = createNode("CaseLabelList", children, 1); }
    | CaseLabelList D_COM LabelRange { struct Node** children = {$1, $3}; $$ = createNode("CaseLabelList", children, 2); }
    ;

LabelRange
    : Label { struct Node** children = {$1}; $$ = createNode("LabelRange", children, 1); }
    | Label D_DDOT Label { struct Node** children = {$1, $3}; $$ = createNode("LabelRange", children, 2); }
    ;

Label
    : T_INTEGER  { struct Node** children; $$ = createNode("INTEGER", children, 0); }
    | T_STRING { struct Node** children; $$ = createNode("STRING", children, 0); }
    | Qualident { struct Node** children = {$1}; $$ = createNode("Label", children, 1); }
    ;

WhileStatement
    : K_WHILE Expression K_DO StatementList WhileElseifStatement K_END { struct Node** children = {$2, $4, $5}; 
                                                                        $$ = createNode("WhileStatement", children, 3); }
    ;

WhileElseifStatement
    : K_ELSIF Expression K_DO StatementList WhileElseifStatement { struct Node** children = {$2, $4, $5}; 
                                                                    $$ = createNode("WhileElseifStatement", children, 3); }
    | /* empty */ { $$ = NULL;}
    ;

RepeatStatement
    : K_REPEAT StatementList K_UNTIL Expression { struct Node** children = {$2, $4}; $$ = createNode("RepeatStatement", children, 2); }
    ;

ForStatement
    : K_FOR Identifier O_ASS Expression K_TO Expression ByStatement K_DO StatementList K_END { struct Node** children = {$2, $4, $6, $7, $9}; 
                                                                                    $$ = createNode("ForStatement", children, 5); }
    ;

ByStatement
    : K_BY ConstExpression { struct Node** children = {$2}; $$ = createNode("ByStatement", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

ModuleBody
    : K_BEGIN StatementList { struct Node** children = {$2}; $$ = createNode("ModuleBody", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

Expression
    : SimpleExpression {struct Node** children = {$1}; $$ = createNode("Expression", children, 1);}
    | SimpleExpression Relation SimpleExpression {struct Node** children = {$1, $2, $3}; $$ = createNode("Expression", children, 3);}
    ;

Relation
    : O_EQ { struct Node** children; $$ = createNode("==", children, 0); }
    | O_NOTEQ { struct Node** children; $$ = createNode("#", children, 0); }
    | O_LT { struct Node** children; $$ = createNode("<", children, 0); }
    | O_LTE { struct Node** children; $$ = createNode("<=", children, 0); }
    | O_GT { struct Node** children; $$ = createNode(">", children, 0); }
    | O_GTE { struct Node** children; $$ = createNode(">=", children, 0); }
    | K_IN { struct Node** children; $$ = createNode("IN", children, 0); }
    | K_IS{ struct Node** children; $$ = createNode("IS", children, 0); }
    ;

SimpleExpression
    : PlusMinus Term AddSequence { struct Node** children = {$1, $2, $3}; $$ = createNode("SimpleExpression", children, 3); }
    ;

PlusMinus
    : O_ADD {struct Node** children; $$ = createNode("Plus", children, 0);}
    | O_SUB {struct Node** children; $$ = createNode("Minus", children, 0);}
    | /* empty */ { $$ = NULL;}
    ;

AddSequence
    : AddOperator Term AddSequence { struct Node** children = {$1, $2, $3}; $$ = createNode("AddSequence", children, 3); }
    | /* empty */ { $$ = NULL;}
    ;

AddOperator
    : O_ADD { struct Node** children; $$ = createNode("ADD", children, 0); }
    | O_SUB { struct Node** children; $$ = createNode("SUBsSTRUCT", children, 0); }
    | K_OR{ struct Node** children; $$ = createNode("OR", children, 0); }
    ;

Term
    : Factor { struct Node** children = {$1}; $$ = createNode("Term", children, 1); }
    | Term MulOperator Factor { struct Node** children = {$1, $2, $3}; $$ = createNode("Term", children, 3); }
    ;

MulOperator
    : O_MUL { struct Node** children; $$ = createNode("Multiplication", children, 0); }
    | O_DIV { struct Node** children; $$ = createNode("Division", children, 0); }
    | K_DIV { struct Node** children; $$ = createNode("/", children, 0); }
    | K_MOD { struct Node** children; $$ = createNode("%", children, 0); }
    | O_AND { struct Node** children; $$ = createNode("&", children, 0); }
    ;

Factor
    : Number { struct Node** children = {$1}; $$ = createNode("Factor", children, 1); }
    | T_STRING { struct Node** children; $$ = createNode("String", children, 0); }
    | K_NIL { struct Node** children; $$ = createNode("NIL", children, 0); }
    | K_TRUE { struct Node** children; $$ = createNode("TRUE", children, 0); }
    | K_FALSE { struct Node** children; $$ = createNode("FALSE", children, 0); }
    | Set { struct Node** children = {$1}; $$ = createNode("Factor", children, 1); }
    | Designator ActualParameter { struct Node** children = {$1, $2}; $$ = createNode("Factor", children, 2); }
    | D_LBR Expression D_RBR  { struct Node** children = {$2}; $$ = createNode("Factor", children, 1); }
    | O_NOT Factor { struct Node** children = {$2}; $$ = createNode("Factor", children, 1); }
    ;

Number
    : T_INTEGER { struct Node** children; $$ = createNode("INTEGER", children, 0); }
    | T_REAL { struct Node** children; $$ = createNode("REAL", children, 0); }
    ;

Set
    : D_LCURBR D_RCURBR { struct Node** children; $$ = createNode("CURVE BR", children, 0); }
    | D_LCURBR Elements D_RCURBR {{ struct Node** children = {$2}; $$ = createNode("Set", children, 1); }}
    ;

Elements
    : Element { struct Node** children = {$1}; $$ = createNode("Elements", children, 1); }
    | Elements D_COM Element { struct Node** children = {$1, $3}; $$ = createNode("Elements", children, 2); }
    ;

Element
    : Expression { struct Node** children = {$1}; $$ = createNode("Element", children, 1); }
    | Expression D_DDOT Expression { struct Node** children = {$1, $3}; $$ = createNode("Element", children, 2); }
    ;

Designator
    : Qualident SelectorSequence { struct Node** children = {$1, $2}; $$ = createNode("Designator", children, 2); }
    ;

SelectorSequence
    : Selector SelectorSequence { struct Node** children = {$1, $2}; $$ = createNode("SelectorSequence", children, 2); }
    | /* empty */ { $$ = NULL;}
    ;

Selector
    : D_DOT Identifier { struct Node** children = {$2}; $$ = createNode("Selector", children, 1); }
    | D_LSQBR ExpList D_RSQBR { struct Node** children = {$2}; $$ = createNode("Selector", children, 1); }
    | O_POINT { struct Node** children; $$ = createNode("POINTER", children, 0); }
    ;

ActualParameter
    : D_LBR D_RBR { struct Node** children; $$ = createNode("NOT PARAM", children, 0); }
    | D_LBR ExpList D_RBR { struct Node** children = {$2}; $$ = createNode("ActualParameter", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

ExpList
    : Expression { struct Node** children = {$1}; $$ = createNode("ExpList", children, 1); }
    | ExpList D_COM Expression { struct Node** children = {$1, $3}; $$ = createNode("ExpList", children, 2); }
    ;

Type
    : Qualident { struct Node** children = {$1}; $$ = createNode("Type", children, 1); }
    | ArrayType { struct Node** children = {$1}; $$ = createNode("Type", children, 1); }
    | RecordType { struct Node** children = {$1}; $$ = createNode("Type", children, 1); }
    | PointerType { struct Node** children = {$1}; $$ = createNode("Type", children, 1); }
    | ProcedureType{ struct Node** children = {$1}; $$ = createNode("Type", children, 1); }
    ;

ArrayType
    : K_ARRAY LengthList K_OF Type { struct Node** children = {$2, $4}; $$ = createNode("ArrayType", children, 2); }
    ;

Length
    : ConstExpression { struct Node** children = {$1}; $$ = createNode("Length", children, 1); }
    ;

LengthList
    : Length { struct Node** children = {$1}; $$ = createNode("LengthList", children, 1); }
    | LengthList D_COM Length { struct Node** children = {$1, $3}; $$ = createNode("LengthList", children, 2); }
    ;

RecordType
    : K_RECORD RecordInheritance RecordFields K_END { struct Node** children = {$2, $3}; $$ = createNode("RecordType", children, 2); }
    ;

RecordInheritance
    : D_LBR BaseType D_RBR { struct Node** children = {$2}; $$ = createNode("RecordInheritance", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

RecordFields
    : FieldListSequence { struct Node** children = {$1}; $$ = createNode("RecordFields", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

BaseType
    : Qualident { struct Node** children = {$1}; $$ = createNode("BaseType", children, 1); }
    ;

FieldListSequence
    : FieldList { struct Node** children = {$1}; $$ = createNode("FieldListSequence", children, 1); }
    | FieldListSequence D_SEM FieldList { struct Node** children = {$1, $3}; $$ = createNode("FieldListSequence", children, 2); }
    ;

FieldList
    : IdentDefList D_COL Type { struct Node** children = {$1, $3}; $$ = createNode("FieldList", children, 2); }
    ;

PointerType
    : K_POINTER K_TO Type { struct Node** children = {$3}; $$ = createNode("PointerType", children, 1); }
    ;

ProcedureType
    : K_PROCEDURE { struct Node** children; $$ = createNode("PROCEDURE", children, 0); }
    | K_PROCEDURE FormalParameters { struct Node** children = {$2}; $$ = createNode("ProcedureType", children, 1); }
    ;

FormalParameters
    : D_LBR FormalArguments D_RBR FormalResult { struct Node** children = {$2, $4}; $$ = createNode("FormalParameters", children, 2); }
    | D_LBR D_RBR FormalResult { struct Node** children = {$3}; $$ = createNode("FormalParameters", children, 1); }
    ;

FormalArguments
    : FormalParametersSection { struct Node** children = {$1}; $$ = createNode("FormalArguments", children, 1); }
    | FormalArguments D_SEM FormalParametersSection { struct Node** children = {$1, $3}; $$ = createNode("FormalArguments", children, 2); }
    ;

FormalResult
    : D_COL Qualident { struct Node** children = {$2}; $$ = createNode("FormalResult", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

FormalParametersSection
    : IdentList D_COL FormalType { struct Node** children = {$1, $3}; $$ = createNode("FormalParametersSection", children, 2); }
    | K_VAR IdentList D_COL FormalType { struct Node** children = {$2, $4}; $$ = createNode("FormalParametersSection", children, 2); }
    ;

IdentList
    : Identifier { struct Node** children = {$1}; $$ = createNode("IdentList", children, 1); }
    | IdentList D_COM Identifier { struct Node** children = {$1, $3}; $$ = createNode("IdentList", children, 2); }
    ;

FormalType
    : FormalTypeSequence Qualident { struct Node** children = {$1, $2}; $$ = createNode("FormalType", children, 2); }
    ;

FormalTypeSequence
    : K_ARRAY K_OF FormalTypeSequence { struct Node** children = {$3}; $$ = createNode("FormalTypeSequence", children, 1); }
    | /* empty */ { $$ = NULL;}
    ;

Qualident
    : Identifier { struct Node** children = {$1}; $$ = createNode("Qualident", children, 1); }
    | Identifier D_DOT Identifier { struct Node** children = {$1, $3}; $$ = createNode("Qualident", children, 1); }
    ;

IdentDefList
    : IdentDef { struct Node** children = {$1}; $$ = createNode("IdentDefList", children, 1); }
    | IdentDefList D_COM IdentDef { struct Node** children = {$1, $3}; $$ = createNode("IdentDefList", children, 2); }
    ;

IdentDef
    : Identifier { struct Node** children = {$1}; $$ = createNode("IdentDef", children, 1); }
    | Identifier O_MUL { struct Node** children = {$1}; $$ = createNode("IdentDef", children, 1); }
    ;

Identifier
    : IDENTIFIER { struct Node** children; $$ = createNode("Identifier", children, 0); }
    | PREDEFINED_IDENTIFIER { struct Node** children; $$ = createNode("predefined", children, 0); }
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
    if (child != NULL)
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
