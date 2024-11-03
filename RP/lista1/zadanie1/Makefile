# Makefile

CC = gcc
CFLAGS = -Wall -Wextra -g
LDFLAGS =

# Targets
all: server client_app

server: server.o
	$(CC) $(LDFLAGS) -o $@ $^

client_app: client_app.o client_lib.o
	$(CC) $(LDFLAGS) -o $@ $^

# Object files
server.o: server.c common.h
	$(CC) $(CFLAGS) -c -o $@ server.c

client_lib.o: client_lib.c client_lib.h common.h
	$(CC) $(CFLAGS) -c -o $@ client_lib.c

client_app.o: client_app.c client_lib.h common.h
	$(CC) $(CFLAGS) -c -o $@ client_app.c

# Clean up
clean:
	rm -f server client_app *.o

.PHONY: all clean
