# Fedora + Infinispan clustering

This sets up a sample cluster of fedora and infinispan.  Two instances of each.  Ideally, all talking to one-another.

Before the first run, you'll need to run setup.sh.  Setup.sh will

1. Clone a couple git repositories
2. Patch the fcrepo4 codebase
3. Compile the code from those git repositories

```bash
./setup.sh
./run.sh
```
# Testing

Testing:

```bash
$ telnet localhost 11211
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
put key 0 0 5
ERROR
set key 0 0 5
12345
STORED
^]

telnet> quit
Connection closed.
$ telnet localhost 11212
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
get key
VALUE key 0 5
12345
END
^]

telnet> quit
Connection closed.

```

Copyright (c) 2015, Regents of the University of Michigan.  
All rights reserved. See LICENSE.txt for details.
