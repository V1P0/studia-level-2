// client_app.c
#include "client_lib.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main() {
    init_client("127.0.0.1");

    // Open a file for writing
    rpc_file_t *file = rpc_open("test.txt", "w+");
    if (file == NULL) {
        printf("Failed to open file for writing\n");
        return -1;
    }

    // Write to the file
    const char *text = "Hello, RPC over UDP!";
    ssize_t bytes_written = rpc_write(file, text, strlen(text));
    if (bytes_written < 0) {
        printf("Failed to write to file\n");
        rpc_close(file);
        return -1;
    } else {
        printf("Wrote %zd bytes to the file.\n", bytes_written);
    }

    // Seek to the beginning
    if (rpc_lseek(file, 0, SEEK_SET) < 0) {
        printf("Failed to seek in file\n");
        rpc_close(file);
        return -1;
    }

    // Read from the file
    char buffer[100];
    ssize_t bytes_read = rpc_read(file, buffer, sizeof(buffer) - 1);
    if (bytes_read < 0) {
        printf("Failed to read from file\n");
        rpc_close(file);
        return -1;
    } else {
        buffer[bytes_read] = '\0'; // Null-terminate the string
        printf("Read %zd bytes from the file: %s\n", bytes_read, buffer);
    }

    // Close the file
    if (rpc_close(file) < 0) {
        printf("Failed to close file\n");
        return -1;
    }

    // Change file permissions
    if (rpc_chmod("test.txt", 0644) < 0) {
        printf("Failed to change file mode\n");
        return -1;
    } else {
        printf("File permissions changed successfully.\n");
    }

    // Rename the file
    if (rpc_rename("test.txt", "renamed_test.txt") < 0) {
        printf("Failed to rename file\n");
        return -1;
    } else {
        printf("File renamed successfully.\n");
    }

    return 0;
}
