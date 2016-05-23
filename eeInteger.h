#ifndef Number_H
#define Number_H
#include "eeExpr.h"

class eeInteger: public eeExpr
{
    private:
         int _value;
              
    public:
        eeInteger(int value);
        ~eeInteger() {}

        void decompile(ostream &os) const;
};

#endif
