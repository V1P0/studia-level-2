// client_lib.h
#ifndef CLIENT_LIB_H
#define CLIENT_LIB_H

#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

// Define a file type for the client
typedef struct {
    int file_id;
} rpc_file_t;

// Initialize the client with the server IP address
void init_client(const char *server_ip);

// Open a file
rpc_file_t *rpc_open(const char *pathname, const char *mode);

// Read from a file
ssize_t rpc_read(rpc_file_t *file, void *buf, size_t count);

// Write to a file
ssize_t rpc_write(rpc_file_t *file, const void *buf, size_t count);

// Seek in a file
off_t rpc_lseek(rpc_file_t *file, off_t offset, int whence);

// Change file mode
int rpc_chmod(const char *pathname, mode_t mode);

// Unlink (delete) a file
int rpc_unlink(const char *pathname);

// Rename a file
int rpc_rename(const char *oldpath, const char *newpath);

// Close a file
int rpc_close(rpc_file_t *file);

#endif // CLIENT_LIB_H
