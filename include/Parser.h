/* A Bison parser, made by GNU Bison 2.1.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     PROGRAM = 258,
     VAR = 259,
     INTEGER = 260,
     REAL = 261,
     BOOLEAN = 262,
     FUNCTION = 263,
     PROCEDURE = 264,
     DD = 265,
     ASSIGN = 266,
     WHILE = 267,
     DO = 268,
     BEG = 269,
     END = 270,
     IF = 271,
     THEN = 272,
     ELSE = 273,
     ARRAY = 274,
     OF = 275,
     TRUE = 276,
     FALSE = 277,
     NOT = 278,
     IDENT = 279,
     INT_NUM = 280,
     REAL_NUM = 281,
     UNARY_OPERATOR = 282,
     IF_PREC = 283
   };
#endif
/* Tokens.  */
#define PROGRAM 258
#define VAR 259
#define INTEGER 260
#define REAL 261
#define BOOLEAN 262
#define FUNCTION 263
#define PROCEDURE 264
#define DD 265
#define ASSIGN 266
#define WHILE 267
#define DO 268
#define BEG 269
#define END 270
#define IF 271
#define THEN 272
#define ELSE 273
#define ARRAY 274
#define OF 275
#define TRUE 276
#define FALSE 277
#define NOT 278
#define IDENT 279
#define INT_NUM 280
#define REAL_NUM 281
#define UNARY_OPERATOR 282
#define IF_PREC 283




#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
#line 18 "../Parser.y"
typedef union YYSTYPE {
	Ident *tIdent;
	Ident_List *tIdent_List;
	Int_Num *tInt_Num;
	Real_Num *tReal_Num;
	Unary_Operator *tUnary_Operator;
	Standard_Type *tStandard_Type;
	Type *tType;
	Parameter *tParameter;
	Parameter_List *tParameter_List;
	Declaration *tDeclaration;
	Declarations *tDeclarations;
	Arguments *tArguments;
	Expression *tExpression;
	Int_Expression *tInt_Expression;
	Real_Expression *tReal_Expression;
	Boolean_Expression *tBoolean_Expression;
	Ident_Expression *tIdent_Expression;
	Expression_Expression *tExpression_Expression;
	Unary_Expression *tUnary_Expression;
	Not_Expression *tNot_Expression;
	Expression_List *tExpression_List;
	Procedure_Statement *tProcedure_Statement;
	Statement *tStatement;
	Statement_List *tStatement_List;
	Optional_Statements *tOptional_Statements;
	Compound_Statement *tCompound_Statement;
	Variable *tVariable;
} YYSTYPE;
/* Line 1447 of yacc.c.  */
#line 124 "../include/Parser.h"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;



