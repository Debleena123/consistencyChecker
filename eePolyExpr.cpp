#include "eePolyExpr.h"

eePolyExpr::eePolyExpr(eeExpr *expr1, eeExpr *expr2): _operand1(expr1),
                        _operand2(expr2)
{}

eePolyExpr::~eePolyExpr()
{
    delete _operand1;
    delete _operand2;
}

void eePolyExpr::decompile(ostream &os) const
{
     
    os << _operand1 << ' ' << _operand2;
}

