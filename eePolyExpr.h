#ifndef POLY_EXPR_H
#define POLY_EXPR_H

#include "eeExpr.h"

class eePolyExpr: public eeExpr
{
    private:
        eeExpr *_operand1;
        eeExpr *_operand2;
      

    public:
        eePolyExpr(eeExpr* expr1, eeExpr* expr2);
        ~eePolyExpr();

        void decompile(ostream &os) const;

};

#endif
