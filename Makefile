CC = gcc
CFLAGS = -g -Wall
INCLUDES = -I.

SRCS = \
	eeExpr.cpp        \
	eeDouble.cpp   \
        eeInteger.cpp      \
	eeNamedExpr.cpp   \
        eeBinaryExpr.cpp  \
	

OBJS = $(SRCS:%.cpp=%.o)

om.lib: $(OBJS)
	ld -r -o $@ $^

%.o: %.cpp
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $<

clean:
	rm -f $(OBJS) om.lib
