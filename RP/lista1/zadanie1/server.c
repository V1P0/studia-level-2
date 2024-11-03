// server.c
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/stat.h>
#include <errno.h>

#define MAX_OPEN_FILES 1024

typedef struct {
    int in_use;
    int fd;
} server_file_t;

static server_file_t open_files[MAX_OPEN_FILES];

void handle_request(int sockfd, struct sockaddr_in *client_addr, socklen_t addr_len, request_t *request) {
    response_t response;
    memset(&response, 0, sizeof(response));

    response.sequence_number = request->sequence_number;

    int status = 0; // Assume success

    // Handle operation
    switch (request->operation) {
        case OP_OPEN: {
            char pathname[512], mode[10];
            sscanf(request->data, "%[^;];%s", pathname, mode);
            int flags = 0;
            if (strcmp(mode, "r") == 0) {
                flags = O_RDONLY;
            } else if (strcmp(mode, "w") == 0) {
                flags = O_WRONLY | O_CREAT | O_TRUNC;
            } else if (strcmp(mode, "a") == 0) {
                flags = O_WRONLY | O_CREAT | O_APPEND;
            } else if (strcmp(mode, "r+") == 0) {
                flags = O_RDWR;
            } else if (strcmp(mode, "w+") == 0) {
                flags = O_RDWR | O_CREAT | O_TRUNC;
            } else if (strcmp(mode, "a+") == 0) {
                flags = O_RDWR | O_CREAT | O_APPEND;
            } else {
                status = -1;
            }
            if (status == 0) {
                int fd = open(pathname, flags, 0666);
                if (fd < 0) {
                    status = -errno;
                } else {
                    int file_id = -1;
                    for (int i = 1; i < MAX_OPEN_FILES; i++) { // Start from 1
                        if (!open_files[i].in_use) {
                            open_files[i].in_use = 1;
                            open_files[i].fd = fd;
                            file_id = i;
                            break;
                        }
                    }
                    if (file_id == -1) {
                        status = -EMFILE; // Too many open files
                        close(fd);
                    } else {
                        memcpy(response.data, &file_id, sizeof(file_id));
                        response.data_length = sizeof(file_id);
                    }
                }
            }
            break;
        }
        case OP_READ: {
            int file_id = request->fd;
            if (file_id <= 0 || file_id >= MAX_OPEN_FILES || !open_files[file_id].in_use) {
                status = -EBADF;
            } else {
                int fd = open_files[file_id].fd;
                size_t count;
                memcpy(&count, request->data, sizeof(count));
                if (count > MAX_BUFFER_SIZE) {
                    count = MAX_BUFFER_SIZE;
                }
                ssize_t n = read(fd, response.data, count);
                if (n < 0) {
                    status = -errno;
                } else {
                    response.data_length = n;
                    status = n;
                }
            }
            break;
        }
        case OP_WRITE: {
            int file_id = request->fd;
            if (file_id <= 0 || file_id >= MAX_OPEN_FILES || !open_files[file_id].in_use) {
                status = -EBADF;
            } else {
                int fd = open_files[file_id].fd;
                ssize_t n = write(fd, request->data, request->data_length);
                if (n < 0) {
                    status = -errno;
                } else {
                    status = n;
                }
            }
            break;
        }
        case OP_LSEEK: {
            int file_id = request->fd;
            if (file_id <= 0 || file_id >= MAX_OPEN_FILES || !open_files[file_id].in_use) {
                status = -EBADF;
            } else {
                int fd = open_files[file_id].fd;
                off_t offset;
                int whence;
                memcpy(&offset, request->data, sizeof(offset));
                memcpy(&whence, request->data + sizeof(offset), sizeof(whence));
                off_t new_offset = lseek(fd, offset, whence);
                if (new_offset < 0) {
                    status = -errno;
                } else {
                    memcpy(response.data, &new_offset, sizeof(new_offset));
                    response.data_length = sizeof(new_offset);
                    status = 0;
                }
            }
            break;
        }
        case OP_CLOSE: {
            int file_id = request->fd;
            if (file_id <= 0 || file_id >= MAX_OPEN_FILES || !open_files[file_id].in_use) {
                status = -EBADF;
            } else {
                int fd = open_files[file_id].fd;
                if (close(fd) < 0) {
                    status = -errno;
                } else {
                    open_files[file_id].in_use = 0;
                    status = 0;
                }
            }
            break;
        }
        case OP_CHMOD: {
            char pathname[512];
            mode_t mode;
            strcpy(pathname, request->data);
            memcpy(&mode, request->data + strlen(pathname) + 1, sizeof(mode));
            if (chmod(pathname, mode) < 0) {
                status = -errno;
            }
            break;
        }
        case OP_UNLINK: {
            char pathname[512];
            strcpy(pathname, request->data);
            if (unlink(pathname) < 0) {
                status = -errno;
            }
            break;
        }
        case OP_RENAME: {
            char oldpath[512], newpath[512];
            sscanf(request->data, "%[^;];%s", oldpath, newpath);
            if (rename(oldpath, newpath) < 0) {
                status = -errno;
            }
            break;
        }
        default:
            status = -1; // Unknown operation
            break;
    }

    response.status_code = status;

    // Send response
    sendto(sockfd, &response, sizeof(response), 0,
           (struct sockaddr *)client_addr, addr_len);
}

int main() {
    int sockfd;
    struct sockaddr_in server_addr, client_addr;
    socklen_t addr_len;

    // Initialize open files array
    memset(open_files, 0, sizeof(open_files));

    // Create UDP socket
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);

    // Bind to specified port
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(SERVER_PORT);
    server_addr.sin_addr.s_addr = INADDR_ANY;
    bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr));

    printf("Server is running and listening on port %d...\n", SERVER_PORT);

    while (1) {
        request_t request;
        addr_len = sizeof(client_addr);

        // Receive request
        int n = recvfrom(sockfd, &request, sizeof(request), 0,
                         (struct sockaddr *)&client_addr, &addr_len);
        if (n > 0) {
            // Handle request
            handle_request(sockfd, &client_addr, addr_len, &request);
        }
    }

    close(sockfd);
    return 0;
}
