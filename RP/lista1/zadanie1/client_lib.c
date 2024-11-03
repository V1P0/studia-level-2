// client_lib.c
#include "common.h"
#include "client_lib.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

static uint64_t auth_token = 0;
static int sockfd;
static struct sockaddr_in server_addr;
static uint64_t sequence_number = 0;

void init_client(const char *server_ip) {
    // Generate auth token
    int fd = open("/dev/urandom", O_RDONLY);
    read(fd, &auth_token, sizeof(auth_token));
    close(fd);

    // Create UDP socket
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);

    // Configure server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(SERVER_PORT);
    inet_aton(server_ip, &server_addr.sin_addr);
}

static int send_request(request_t *request, response_t *response) {
    // Set authentication token and sequence number
    request->auth_token = auth_token;
    request->sequence_number = ++sequence_number;

    // Send request
    sendto(sockfd, request, sizeof(*request), 0,
           (struct sockaddr *)&server_addr, sizeof(server_addr));

    // Set timeout
    struct timeval tv;
    tv.tv_sec = TIMEOUT_SECONDS;
    tv.tv_usec = 0;
    setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    // Wait for response
    socklen_t addr_len = sizeof(server_addr);
    int n = recvfrom(sockfd, response, sizeof(*response), 0,
                     (struct sockaddr *)&server_addr, &addr_len);

    if (n < 0) {
        // Timeout or error
        perror("recvfrom failed");
        return -1;
    }

    // Verify sequence number
    if (response->sequence_number != request->sequence_number) {
        fprintf(stderr, "Sequence number mismatch\n");
        return -1;
    }

    return response->status_code;
}

rpc_file_t *rpc_open(const char *pathname, const char *mode) {
    request_t request = {0};
    response_t response = {0};

    request.operation = OP_OPEN;
    snprintf(request.data, sizeof(request.data), "%s;%s", pathname, mode);
    request.data_length = strlen(request.data) + 1;

    int status = send_request(&request, &response);
    if (status == 0) {
        int file_id;
        memcpy(&file_id, response.data, sizeof(file_id));
        rpc_file_t *file = malloc(sizeof(rpc_file_t));
        file->file_id = file_id;
        return file;
    } else {
        printf("rpc_open failed with status %d\n", status);
        return NULL;
    }
}

ssize_t rpc_read(rpc_file_t *file, void *buf, size_t count) {
    request_t request = {0};
    response_t response = {0};

    request.operation = OP_READ;
    request.fd = file->file_id;
    memcpy(request.data, &count, sizeof(count));
    request.data_length = sizeof(count);

    int status = send_request(&request, &response);
    if (status >= 0) {
        memcpy(buf, response.data, response.data_length);
        return response.data_length;
    } else {
        return -1;
    }
}

ssize_t rpc_write(rpc_file_t *file, const void *buf, size_t count) {
    request_t request = {0};
    response_t response = {0};

    request.operation = OP_WRITE;
    request.fd = file->file_id;
    memcpy(request.data, buf, count);
    request.data_length = count;

    int status = send_request(&request, &response);
    if (status >= 0) {
        return status;
    } else {
        return -1;
    }
}

off_t rpc_lseek(rpc_file_t *file, off_t offset, int whence) {
    request_t request = {0};
    response_t response = {0};

    request.operation = OP_LSEEK;
    request.fd = file->file_id;
    memcpy(request.data, &offset, sizeof(offset));
    memcpy(request.data + sizeof(offset), &whence, sizeof(whence));
    request.data_length = sizeof(offset) + sizeof(whence);

    int status = send_request(&request, &response);
    if (status >= 0) {
        off_t new_offset;
        memcpy(&new_offset, response.data, sizeof(new_offset));
        return new_offset;
    } else {
        return (off_t)-1;
    }
}

int rpc_chmod(const char *pathname, mode_t mode) {
    request_t request = {0};
    response_t response = {0};

    request.operation = OP_CHMOD;
    snprintf(request.data, sizeof(request.data), "%s", pathname);
    memcpy(request.data + strlen(request.data) + 1, &mode, sizeof(mode));
    request.data_length = strlen(request.data) + 1 + sizeof(mode);

    int status = send_request(&request, &response);
    return status;
}

int rpc_unlink(const char *pathname) {
    request_t request = {0};
    response_t response = {0};

    request.operation = OP_UNLINK;
    snprintf(request.data, sizeof(request.data), "%s", pathname);
    request.data_length = strlen(request.data) + 1;

    int status = send_request(&request, &response);
    return status;
}

int rpc_rename(const char *oldpath, const char *newpath) {
    request_t request = {0};
    response_t response = {0};

    request.operation = OP_RENAME;
    snprintf(request.data, sizeof(request.data), "%s;%s", oldpath, newpath);
    request.data_length = strlen(request.data) + 1;

    int status = send_request(&request, &response);
    return status;
}

int rpc_close(rpc_file_t *file) {
    request_t request = {0};
    response_t response = {0};

    request.operation = OP_CLOSE;
    request.fd = file->file_id;
    request.data_length = 0;

    int status = send_request(&request, &response);
    free(file);
    return status;
}
