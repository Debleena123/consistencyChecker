#ifndef CONST_EXPR_H
#define CONST_EXPR_H
#include "eeExpr.h"

class eeDouble: public eeExpr
{
    private:
         double _value;
              
    public:
        eeDouble(double value);
        ~eeDouble() {}
      
        void decompile(ostream &os) const;       
       
};

#endif
