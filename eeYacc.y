%{

#include <map>
#include <cstdlib>
using namespace std;

#include <string.h>
#include "eeDefines.h"
#include "eeVar.h"
#include "eeExpr.h"
#include "eeDouble.h"
#include "eeNamedExpr.h"
#include "eeInteger.h"
#include "eeBinaryExpr.h"


int yylex();
void yyerror(const char*);

static bool debug = false;
static string INT = "int", CHAR = "char", BOOL = "bool", DOUBLE = "double", TYPE;
static bool intflag = 0, charflag = 0, boolflag = 0, doubleflag = 0, assertflag = 0; 
static bool numflag = 0, andFlag = 0, orFlag = 0;
map<string, eeVar*> varSymTab;
eeExpr *store,*andStore;
eeBinaryExpr *stack[10];
int count = 0, top = 0, stackString_Top = 0;
char stackString[10];


%}

%union
{
    char *str;
    double value;
    eeExpr *expr;
    eeVar *idlist;
}

%token <str> ID
%token <str> KWD
%token <str> STMT
%token <value> NUMBER
%token ERROR
%type <expr> expr

%right AND OR LE GE '<' '>''='
%left EQ NE '?' '-' '+'
%left '*' '/'
%nonassoc UMINUS

%start program

%%

program: program VarDeclStmt | VarDeclStmt | program asStmt | asStmt;

VarDeclStmt: KWD { if(strcmp($1,"char") == 0) charflag = 1;
             else if(strcmp($1,"int") == 0) intflag = 1;
             else if(strcmp($1,"bool") == 0) boolflag = 1;
             else if(strcmp($1,"double") == 0) doubleflag = 1;} 
       idlist  ';'
     {
     	charflag = 0;
     	intflag = 0;
     	boolflag = 0;
     	doubleflag = 0;
     }

asStmt: STMT expr  ';'    
      {

        if((andFlag == 1) || (orFlag == 1))
         {
            cout << "(assert ";
          top = top - 1;
          stackString_Top = stackString_Top - 1;
          if(stackString[stackString_Top] == 'a')
           {
            eeBinaryExpr *node = new eeBinaryExpr(EEOP_AND, stack[top], stack[top - 1]);
            stackString_Top = stackString_Top - 1;
            stack[top -1] = node;
            top = top - 1;             
           }
          else if(stackString[stackString_Top] == 'o')
           {
            eeBinaryExpr *node = new eeBinaryExpr(EEOP_OR, stack[top], stack[top - 1]);
            stackString_Top = stackString_Top - 1;
            stack[top -1] = node;
            top = top - 1;
           }
           if(top > -1)
           {             
             while(top > 0)
              {
                if(stackString[stackString_Top] == 'a')
                   {
            	     eeBinaryExpr *node = new eeBinaryExpr(EEOP_AND, stack[top], stack[top - 1]);
            	     stackString_Top = stackString_Top - 1;
            	     stack[top - 1] = node;
            	     top = top - 1;                            			
           	   }
          	else if(stackString[stackString_Top] == 'o')
           	   {
            	     eeBinaryExpr *node = new eeBinaryExpr(EEOP_OR, stack[top], stack[top - 1]);
            	     stackString_Top = stackString_Top - 1;
            	     stack[top - 1] = node;
            	     top = top - 1;			                
           	   }
              }
           }
          
          	stack[top]->decompile(std::cout);
          	cout << ')' << endl;
               andFlag = 0;
               orFlag = 0; 
         }
        
      else
       {  
         top = top-1;           
         if(top > -1)
	 {           
           while(top != -1 )
           {
             cout << "(assert" ;
             stack[top]->decompile(std::cout);          
	     cout<<")"<<endl;
             top = top - 1;
           }
	 }
        }        
        //delete $2;   
        assertflag = 0;
        count = 0;
        charflag = 0;
        intflag = 0;
        boolflag = 0;
        doubleflag = 0;
        top = 0;
      }

expr:expr '+' expr
    {
        $$ = new eeBinaryExpr(EEOP_PLUS, $1, $3);
    }
    | expr '-' expr
    {
        $$ = new eeBinaryExpr(EEOP_MINUS, $1, $3);
    }
    | expr '*' expr
    {
        $$ = new eeBinaryExpr(EEOP_MUL, $1, $3);
    }
    | expr '/' expr
    {
        $$ = new eeBinaryExpr(EEOP_DIV, $1, $3);
    }
    |expr AND expr
     {       
       count = 0;
       andFlag = 1;
       stackString[stackString_Top] = 'a';
       stackString_Top = stackString_Top + 1;      
     }
     |expr OR expr
     {
       count = 0;
       orFlag = 1;
       stackString[stackString_Top] = 'o';
       stackString_Top = stackString_Top + 1;      
     }
    | expr LE expr
    {
       if(count >= 1)
        {
          eeBinaryExpr *node = new eeBinaryExpr(EEOP_LE, $1, store);
          stack[top] = node;          
          top = top + 1;
          store = $1;
          count = count + 1; 
        }
       else
       {
	 eeBinaryExpr *node = new eeBinaryExpr(EEOP_LE,$1, $3); 
         stack[top] = node;         
         top = top + 1; 
         store = $1;
         count = count + 1; 
       }
          
    } 
    | expr '<' expr
    {
      if(count >= 1)
        {
          eeBinaryExpr *node = new eeBinaryExpr(EEOP_LT, $1, store);
          stack[top] = node;          
          top = top + 1;
          store = $1;
          count = count + 1; 
         }
       else
        {
	 eeBinaryExpr *node = new eeBinaryExpr(EEOP_LT,$1, $3); 
         stack[top] = node;         
         top = top + 1; 
         store = $1;
         count = count + 1; 
        }
            
    } 
    | expr GE expr
    {
        
        if(count >= 1)
        {
          eeBinaryExpr *node = new eeBinaryExpr(EEOP_GE, $1, store);
          stack[top] = node;
          top = top + 1;
          store = $1;
          count = count + 1; 
         }
       else
        {
	 eeBinaryExpr *node = new eeBinaryExpr(EEOP_GE,$1, $3); 
         stack[top] = node;         
         top = top + 1; 
         store = $1;
         count = count + 1; 
        }
    }
    | expr '>' expr
    {
       
        if(count >= 1)
        {
          eeBinaryExpr *node = new eeBinaryExpr(EEOP_GT, $1, store);
          stack[top] = node;          
          top = top + 1;
          store = $1;
          count = count + 1; 
         }
       else
        {
	 eeBinaryExpr *node = new eeBinaryExpr(EEOP_GT,$1, $3); 
         stack[top] = node;        
         top = top + 1; 
         store = $1;
         count = count + 1; 
        }     
    }
    |expr '=' expr
    {
       eeBinaryExpr *node = new eeBinaryExpr(EEOP_IQ,$1, $3); 
       stack[top] = node;        
       top = top + 1; 
       //store = $1;
       count = count + 1;       
    }
    | expr EQ expr
    {
        eeBinaryExpr *node = new eeBinaryExpr(EEOP_EQ,$1, $3); 
        stack[top] = node;        
        top = top + 1; 
        //store = $1;
        count = count + 1;        
    }
    | expr NE expr
    {
        $$ = new eeBinaryExpr(EEOP_NE, $1, $3);
    }
    | '(' expr ')'
    {
        $$ = $2;
    }
    | NUMBER
    { 
         numflag = 0;
         if(doubleflag == 1)
          $$ = new eeDouble($1);
         else
         $$ = new eeInteger($1);
    }
    | ID
    {
       if (varSymTab.find($1) == varSymTab.end())
        { 
            if (debug)
                cout << "> creating variable: " << $1 << endl;
            
	    yyerror($1);
        }
        eeVar *var = varSymTab[$1];
        $$ = new eeNamedExpr(var);
        TYPE = var->getType();

        if(TYPE == "char") charflag = 1;
        else if(TYPE == "int") intflag = 1;
        else if(TYPE == "bool") boolflag = 1;
        else if(TYPE == "double") doubleflag = 1;
        
        free($1);
    }
    
 idlist: idlist ',' idlist
       { 
       }
       | ID 
       {
        if (varSymTab.find($1) == varSymTab.end())
        {
            if (debug)
                cout << "> creating variable: " << $1 << endl;
            varSymTab[$1] = new eeVar($1);
            eeVar *vardefine = varSymTab[$1];

            if(charflag == 1)
             vardefine->setType(CHAR);
            else if(intflag == 1)
             vardefine->setType(INT);
            else if(boolflag == 1)
             vardefine->setType(BOOL);
            else if(doubleflag == 1)
             vardefine->setType(DOUBLE);

            vardefine->decompiletoyices(std::cout); 
            
        }
       else
        {
           yyerror($1);
        }
       free($1);
      } 
      ;

%%

void yyfinalize()
{
    if (debug)
        cout << "> Variables created:" << endl;
    map<string, eeVar*>::iterator iter;   
    for(iter = varSymTab.begin(); iter != varSymTab.end(); iter++)
    {
        if (debug)
            cout << iter->first << " : " <<
                fixed << iter->second->getValue() << endl;
        delete iter->second;
    }
    varSymTab.clear();
}
