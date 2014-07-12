#!/bin/sh
make clean
make all

echo \`false\` exits without reading its input
echo simple_cat tries to write to false and gets SIGPIPE, terminating it
echo hit enter to run:
echo '/bin/sh -c "yes|head -c 4097 | strace -eread,write ./simple_cat | false"'
read trash
/bin/sh -c "yes|head -c 4097 | strace -eread,write ./simple_cat | false"

echo
echo
echo ignore_pipe_exec ignores SIGPIPE for its children, so this same program now loops forever
echo "as it doesn't explicitly check whether its read() calls are returning data (EOF)"
echo hit enter to run:
echo './ignore_pipe_exec /bin/sh -c "yes|head -c 4097| strace -eread,write ./simple_cat | false"'
echo YOU WIll NEED TO ^C THIS, IT WILL RUN FOREVER
read trash
./ignore_pipe_exec /bin/sh -c "yes|head -c 4097| strace -eread,write ./simple_cat | false"

echo
echo
echo A better program will check for EOF and exit, even without SIGPIPE
echo Ignoring SIGPIPE only breaks moderately buggy programs in a pipeline
echo hit enter to run:
echo './ignore_pipe_exec /bin/sh -c "yes|head -c 4097| strace -eread,write ./better_cat | false"'
./ignore_pipe_exec /bin/sh -c "yes|head -c 4097| strace -eread,write ./better_cat | false"

