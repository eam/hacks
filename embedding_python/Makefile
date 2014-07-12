# this makefile targeting osx brew paths
all:
	gcc -Wall embed_py.c -o embed_py `/usr/local/bin/python-config --includes` `/usr/local/bin/python-config --ldflags`
#	gcc -Wall embed_py.c -o embed_py -I/usr/local/include/python2.7 -L/usr/local/lib/python2.7 -lpython

clean:
	rm -f embed_py *.o *.so
