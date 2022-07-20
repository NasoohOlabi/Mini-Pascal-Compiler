%{
	#include "ast.h"
	#include <iostream>

	using std::cout;
	using std::endl;	
	extern int yylex();
	extern int yyerror(const char *);
	int lin = 1, col =0;

	Program *root;
	std::map<string, Subprogram_Declaration> funcs;
	std::map<string, bool> visited;
	SymbolTable *symbolTable = new SymbolTable();

%}


/* Union Definition Section */

%union{
	Ident *tIdent;
	Ident_List *tIdent_List;
	Int_Num *tInt_Num;
	Real_Num *tReal_Num;
	Standard_Type *tStandard_Type;
	Type *tType;
	Parameter *tParameter;
	Parameter_List *tParameter_List;
	Declaration *tDeclaration;
	Declarations *tDeclarations;
	Local_Declaration *tLocal_Declaration;
	Local_Declarations *tLocal_Declarations;
	Arguments *tArguments;
	Expression *tExpression;
	Int_Expression *tInt_Expression;
	Real_Expression *tReal_Expression;
	Boolean_Expression *tBoolean_Expression;
	Function_Expression *tFunction_Expression;
	Ident_Expression *tIdent_Expression;
	Expression_Expression *tExpression_Expression;
	Not_Expression *tNot_Expression;
	Expression_List *tExpression_List;
	Procedure_Statement *tProcedure_Statement;
	Statement *tStatement;
	Statement_List *tStatement_List;
	Optional_Statements *tOptional_Statements;
	Compound_Statement *tCompound_Statement;
	Return_Statement *tReturn_Statement;
	Variable *tVariable;
	Subprogram_Head *tSubprogram_Head;
	Subprogram_Declaration *tSubprogram_Declaration;
	Subprogram_Declarations *tSubprogram_Declarations;
	Program *tProgram;
	Add_expression *tAdd_expression;
	Minus_expression *tMinus_expression;
	Mul_expression *tMul_expression;
	Divide_expression *tDivide_expression;
	Binary_expression *tBinary_expression;
	Logical_expression *tLogical_expression;
	Array_expression *tArray_expression;
	Binary_opreator *tBinary_Opreator;
	Logical_opreator *tLogical_Opreator;
 }

/* Tokens Section (Terminals) */

%token PROGRAM INTEGER REAL BOOLEAN DD ASSIGN RET ENDWHILE
%token WHILE DO BEG END IF THEN ARRAY OF TRUE FALSE ENDIF
%token <tIdent> IDENT
%token <tInt_Num> INT_NUM
%token <tReal_Num> REAL_NUM


/* Precedences & Priorities Section */



%left '+' '-'
%left '*' '/'
%left <tLogical_Opreator> LOGICAL_OPERATOR

%nonassoc <tBinary_Opreator> BINARY_OPERATOR

%nonassoc EXPRLST_PREC



%nonassoc IF_PREC
%nonassoc ELSE

%nonassoc WHILE_PREC
%nonassoc DO

%nonassoc NOSUBDECS_PREC
%nonassoc FUNCTION
%nonassoc PROCEDURE
%nonassoc SUBPROGRAMDEC_PREC
%nonassoc SUBDECS_PREC


%nonassoc NODECS_PREC
%nonassoc VAR

%nonassoc UNARY_PREC
%nonassoc NOT

%nonassoc EXPR_PREC
%nonassoc ','



/* Types Section (Non-Terminals) */

%type <tIdent_List> ident_list
%type <tStandard_Type> standard_type
%type <tType> type
%type <tParameter> parameter
%type <tParameter_List> parameter_list
%type <tDeclaration> declaration
%type <tDeclarations> declarations
%type <tLocal_Declaration> local_declaration
%type <tLocal_Declarations> local_declarations
%type <tArguments> arguments
%type <tExpression> expression
%type <tExpression_List> expression_list
%type <tProcedure_Statement> procedure_statement
%type <tVariable> variable
%type <tStatement> statement
%type <tStatement_List> statement_list
%type <tOptional_Statements> optional_statements
%type <tCompound_Statement> compound_statement
%type <tSubprogram_Head> subprogram_head
%type <tSubprogram_Declaration> subprogram_declaration
%type <tSubprogram_Declarations> subprogram_declarations
%type <tProgram> program
%type <tAdd_expression> add_expression
%type <tMinus_expression> minus_expression
%type <tMul_expression> mul_expression
%type <tDivide_expression> divide_expression
%type <tBinary_expression> binary_expression
%type <tLogical_expression> logical_expression
%type <tArray_expression> array_expression


%%

program: PROGRAM IDENT ';' declarations subprogram_declarations compound_statement 
	{
		$$ = new Program($2, $4, $5, $6, lin, col);
		root = $$;
	}


subprogram_declarations: subprogram_declarations subprogram_declaration ';' %prec SUBDECS_PREC
								{
									$1->AddDec($2);
									$$ = $1;
								}
							| /* Empty */ %prec NOSUBDECS_PREC
								{
									$$ = new Subprogram_Declarations(lin, col);
								}
;


subprogram_declaration: { symbolTable->startScope(); }
						subprogram_head local_declarations compound_statement 
						{ symbolTable->endScope(); } %prec SUBPROGRAMDEC_PREC
							{
								string name = $2->ident->name;

								$$ = new Subprogram_Declaration($3, $2, $4, lin, col);
								Subprogram_Declaration sd = *$$;

								funcs.insert({name, sd});
							}
;

subprogram_head: FUNCTION IDENT arguments ':' standard_type ';'
					{
						$$ = new Subprogram_Head($2, $3, $5, lin, col);

						symbolTable->AddFunction($2, $3, 1, $5->type, false); // 1 is Function
					}
				| PROCEDURE IDENT arguments ';'
					{
						$$ = new Subprogram_Head($2, $3, lin, col);

						symbolTable->AddFunction($2, $3, 2, 'x', false); // 2 is Procedure
					}
;

variable: IDENT
				{
					Symbol* s = symbolTable->lookUpSymbol($1);

					if(s == NULL)
					{
						cout << "\n\nError:: Undeclared variable " << $1->name << ", line " << $1->line << ", col " << $1->column << "\n\n";
					}

					$$ = new Variable($1, lin, col);
				}
			| IDENT '[' expression ']'
				{
					Symbol* s = symbolTable->lookUpSymbol($1);

					int value = ((Int_Expression*)$3)->value->value;
					int first = s->first;
					int last = s->last;

					if(!(value >= first && value <= last)){
						cout << "Error: index out of range, line " << $1->line;
					}

					if(s == NULL)
					{
						cout << "\n\nError:: Undeclared variable " << $1->name << ", line " << $1->line << ", col " << $1->column << "\n\n";
					}


					$$ = new Variable($1, $3, lin, col);
				}
;


procedure_statement: IDENT
							{
								$$ = new Procedure_Statement($1, lin, col);
							}
					| IDENT '(' expression_list ')'
							{
								$$ = new Procedure_Statement($1, $3, lin, col);
							}
;


expression_list: expression %prec EXPRLST_PREC
						{
							$$ = new Expression_List($1 ,lin, col);
						}
						| expression_list ',' expression 
						{
							$1->AddExpr($3);
							$$ = $1;
						}
;

expression: INT_NUM
								{
									$$ = new Int_Expression($1, lin, col);
								}			
			| REAL_NUM
								{
									$$ = new Real_Expression($1, lin, col);
								}
			| TRUE
								{
									$$ = new Boolean_Expression(true, lin, col);
								}
			| FALSE
								{
									$$ = new Boolean_Expression(false, lin, col);
								}
			| NOT expression
								{
									$$ = new Not_Expression($2 ,lin, col);
								}
			| add_expression
								{
									$$ = $1;
								}
			| minus_expression
								{
									$$ = $1;
								}			
			| mul_expression
								{
									$$ = $1;
								}			
			|divide_expression
								{
									$$ = $1;
								}								
			| binary_expression %prec UNARY_PREC
								{
									$$ = $1;
								}
			| logical_expression %prec UNARY_PREC
								{
									$$ = $1;
								}
			| array_expression
								{
									$$ = $1;
								}
			| IDENT '(' expression_list ')' %prec EXPR_PREC
								{			
									string ss = "";					
									Symbol *s = symbolTable->lookUpFunction($1, $3, 1, ss);

								
									if(s == NULL){
										cout << "\n\nError:: Undeclared function " << $1->name << ", line " << $1->line << ", col " << $1->column << "\n\n";
									}
									$$ = new Function_Expression($1, $3 ,lin, col);
								}
			| IDENT 
								{
									Symbol *s = symbolTable->lookUpSymbol($1);
									string ss = "";
									if(s == NULL){
										s = symbolTable->lookUpFunction($1, NULL, 1, ss);
										if(s == NULL){
											cout << "\n\nError:: Undeclared variable " << $1->name << ", line " << $1->line << ", col " << $1->column << "\n\n";
											$$ = new Ident_Expression($1, lin, col);
										}
										else{
											$$ = new Function_Expression($1, lin, col);
										}
									}
									else{
										$$ = new Ident_Expression($1, lin, col);
									}
									
								}
			| '(' expression ')'
								{
									$$ = new Expression_Expression($2 ,lin, col);
								}
;

arguments: '(' parameter_list ')'
						{
							$$ = new Arguments($2 ,lin, col);
							int n = $2->params->size();

							for(int i=0;i<n;i++){

								Parameter *p = $2->params->at(i);
								bool is_arr = p->type->is_array;

								int s = p->ident_list->idents->size();
								char t = p->type->std_type->type;

								if(is_arr){
									int first = p->type->first;
									int last = p->type->last;
									for(int j=0;j<s;j++){
										symbolTable->AddSymbol(p->ident_list->idents->at(j),2,t, is_arr, first, last);
									}
								}
								else{
									for(int j=0;j<s;j++){
										symbolTable->AddSymbol(p->ident_list->idents->at(j),2,t, is_arr);
									}
								}

								

							}
						}
			| /* Empty */
				{
					Parameter_List *pl = new Parameter_List(lin, col);
					$$ = new Arguments(pl, lin, col);
				}
;

declarations: declaration
						{
							$$ = new Declarations($1 ,lin, col);
						}
			| declarations declaration
				{
					$1->AddDec($2);
					$$ = $1;
				}
			| /* Empty */  %prec NODECS_PREC
				{
					$$ = new Declarations(lin, col);
				}
;

declaration: VAR parameter ';'	
										{
											$$ = new Declaration($2, lin, col);
											bool is_arr = $2->type->is_array;
											char t = $2->type->std_type->type;
											int n = $2->ident_list->idents->size();
											if(is_arr){
												int f = $2->type->first;
												int l = $2->type->last;
												for(int i=0;i<n;i++){
													symbolTable->AddSymbol($2->ident_list->idents->at(i),1,t, is_arr, f, l);
												}
											}
											else{
												for(int i=0;i<n;i++){
													symbolTable->AddSymbol($2->ident_list->idents->at(i),1,t, is_arr);
												}
											}
											
										}
;

local_declarations: local_declaration
						{
							$$ = new Local_Declarations($1 ,lin, col);
						}
			| local_declarations local_declaration
				{
					$1->AddDec($2);
					$$ = $1;
				}
			| /* Empty */  %prec NODECS_PREC
				{
					$$ = new Local_Declarations(lin, col);
				}
;

local_declaration: VAR parameter ';'	
										{
											$$ = new Local_Declaration($2, lin, col);

											char t = $2->type->std_type->type;
											bool is_arr = $2->type->is_array;
											int n = $2->ident_list->idents->size();
											if(is_arr){
												int f = $2->type->first;
												int l = $2->type->last;
												for(int i=0;i<n;i++){
													symbolTable->AddSymbol($2->ident_list->idents->at(i),1,t, is_arr, f, l);
												}
											}
											else{
												for(int i=0;i<n;i++){
													symbolTable->AddSymbol($2->ident_list->idents->at(i),1,t, is_arr);
												}
											}
										}
;

parameter_list: parameter
						{
							$$ = new Parameter_List($1 ,lin, col);
						}
						| parameter_list ';' parameter
						{
							$1->AddParam($3);
							$$ = $1;
						}
;

parameter: ident_list ':' type	{
									$$ = new Parameter($1, $3, lin, col);
									// int n = $1->idents->size();
									// char t = $3->std_type->type;
									// for(int i=0;i<n;i++){
									// 	symbolTable->AddSymbol($1->idents->at(i),2,t);
									// }
								}
;

type: standard_type 
					{
						$$ = new Type($1, lin, col);
					}
				| ARRAY '[' INT_NUM DD INT_NUM ']' OF standard_type
					{
						$$ = new Type($8, $3->value, $5->value, lin, col);
					}			
;

add_expression: expression '+' expression 
					{
						$$ = new Add_expression($1, $3, lin, col);
					}
;

minus_expression: expression '-' expression 
				{
						$$ = new Minus_expression($1, $3, lin, col);
				}
;

mul_expression: expression '*' expression 
				{
						$$ = new Mul_expression($1, $3, lin, col);
				}
;

divide_expression: expression '/' expression 
				{
						$$ = new Divide_expression($1, $3, lin, col);
				}
;

binary_expression: expression BINARY_OPERATOR expression 
				{
						$$ = new Binary_expression($1, $2, $3, lin, col);
				}
;

logical_expression: expression LOGICAL_OPERATOR expression 
				{
						$$ = new Logical_expression($1, $2, $3, lin, col);
				}
;

array_expression: IDENT '[' expression ']'
				{
						$$ = new Array_expression($1, $3, lin, col);

						Symbol* s = symbolTable->lookUpSymbol($1);

						int value = ((Int_Expression*)$3)->value->value;
						int first = s->first;
						int last = s->last;
				

						if(!(value >= first && value <= last)){
							cout << "Error: index out of range, line " << $1->line;
						}

						if(s == NULL)
						{
							cout << "\n\nError:: Undeclared variable " << $1->name << ", line " << $1->line << ", col " << $1->column << "\n\n";
						}
						else{
							$$->symbol = s;
						}
				}
;

standard_type: INTEGER 
					{
						$$ = new Standard_Type('I', lin, col);
					}
				| REAL
					{
						$$ = new Standard_Type('R', lin, col);
					}			
				| BOOLEAN
					{
						$$ = new Standard_Type('B', lin, col);
					}
;

ident_list: IDENT
		{
			$$ = new Ident_List($1, lin, col);
		}
			| ident_list ',' IDENT
		{
			$1->AddIdent($3);
			$$ = $1;
		}
;

statement : variable ASSIGN expression
									{
										$$= new Variable_Statement($1, $3, lin, col);
									}
			| procedure_statement
									{
										$$ = $1;
									}
			| RET expression
									{
										$$ = new Return_Statement($2, lin, col);
									}
			| compound_statement
									{
										$$= new Compound_Statement($1->optional_statements, lin, col);
									}

			| IF expression THEN statement_list ENDIF %prec IF_PREC
									{
										$$= new If_Statement($2, $4, lin, col);
									}

			| IF expression THEN statement_list ELSE statement_list ENDIF
									{
										$$= new If_Else_Statement($2, $4, $6, lin, col);
									}
			| WHILE expression DO statement_list ENDWHILE %prec WHILE_PREC
									{
										$$= new While_Statement($2, $4, lin, col);
									}
;

statement_list : statement
					{
						$$= new Statement_List($1, lin, col);
					}
				 | statement_list ';' statement
				 	{
						$1->AddStatement($3); 
						$$ = $1;
					}
;

optional_statements: statement_list
					{
						$$= new Optional_Statements($1, lin, col);
					}
					| /* Empty */
					{
						$$= new Optional_Statements(lin, col);
					}
;

compound_statement: BEG optional_statements END
					{
						$$= new Compound_Statement($2, lin, col);
					}
;


%%

int yyerror(const char* s)
{
	cout << "OOPs, synatx error, line " << lin << ", col " << col << endl;
	return 1;
}
