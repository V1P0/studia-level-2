// common.h
#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>

#define SERVER_PORT 12345
#define MAX_BUFFER_SIZE 1024
#define TIMEOUT_SECONDS 2

// Define operation codes
typedef enum {
    OP_OPEN,
    OP_READ,
    OP_WRITE,
    OP_LSEEK,
    OP_CHMOD,
    OP_UNLINK,
    OP_RENAME,
    OP_CLOSE
} operation_t;

// Request packet structure
typedef struct {
    uint64_t auth_token;
    uint64_t sequence_number;
    operation_t operation;
    int32_t fd; // For operations that require a file descriptor
    uint32_t data_length;
    char data[MAX_BUFFER_SIZE];
} request_t;

// Response packet structure
typedef struct {
    uint64_t sequence_number;
    int32_t status_code;
    uint32_t data_length;
    char data[MAX_BUFFER_SIZE];
} response_t;

#endif // COMMON_H
