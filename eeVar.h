#ifndef VAR_H
#define VAR_H

#include "eeDefines.h"

class eeVar
{
    private:
        const string _name;
        double _value;
        string _type;

    public:
        eeVar(const string &name, double value = 0,const string type="void"):
            _name(name), _value(value), _type(type)
        {}
        ~eeVar() {}

        string getName() const
        { return _name; }

        double getValue() const
        { return _value; }

        void setValue(double value)
        { _value = value; }
     
        void setType(const string type)
        { _type = type;  }
       
        string getType() const
        { return _type; }

        void decompile(ostream &os) const
        {
        os<<_name;
        }

        void decompiletoyices(ostream &os) 
        {
        os<<"(define "<<_name<<"::"<<_type<<")"<<endl;
        }
};

#endif
