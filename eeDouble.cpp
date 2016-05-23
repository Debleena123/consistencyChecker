#include"eeDouble.h"

eeDouble::eeDouble(double value): _value(value)
{}

void eeDouble::decompile(ostream &os) const
{
    os << fixed << _value;
}

