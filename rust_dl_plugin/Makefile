rustlib:
	rustc rangebe.rs

link: rustlib
	gcc -L. -lrangebe stub.c -o stub

run: link
	LD_LIBRARY_PATH=/usr/local/lib:. ./stub

clean:
	rm -f  librangebe.so stub
