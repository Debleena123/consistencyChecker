#include"eeInteger.h"

eeInteger::eeInteger(int value): _value(value)
{}


void eeInteger::decompile(ostream &os) const
{
    os << fixed << _value;
}
