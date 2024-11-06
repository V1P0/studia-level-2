#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <mbedtls/md5.h>

// Funkcja do zamiany endianness 32-bitowego słowa
uint32_t swap_endian32(uint32_t val) {
    return ((val << 24) & 0xff000000) |
           ((val << 8)  & 0x00ff0000) |
           ((val >> 8)  & 0x0000ff00) |
           ((val >> 24) & 0x000000ff);
}

// Funkcja do obliczenia MD5 dwóch bloków
void compute_md5_two_blocks(uint32_t M0[16], uint32_t M1[16], unsigned char output[16]) {
    mbedtls_md5_context ctx;
    unsigned char data_block[64];
    int i;

    mbedtls_md5_init(&ctx);
    mbedtls_md5_starts(&ctx);

    // Przetwarzanie pierwszego bloku M0
    for (i = 0; i < 16; i++) {
        // uint32_t word_le = swap_endian32(M0[i]);
        uint32_t word_le = M0[i];
        memcpy(&data_block[i * 4], &word_le, 4);
    }
    mbedtls_md5_update(&ctx, data_block, 64);

    // Przetwarzanie drugiego bloku M1
    for (i = 0; i < 16; i++) {
        // uint32_t word_le = swap_endian32(M1[i]);
        uint32_t word_le = M1[i];
        memcpy(&data_block[i * 4], &word_le, 4);
    }
    mbedtls_md5_update(&ctx, data_block, 64);

    // Zakończenie obliczeń i pobranie wyniku
    mbedtls_md5_finish(&ctx, output);
    mbedtls_md5_free(&ctx);
}

// Funkcja do sprawdzenia, czy skrót MD5 dwóch bloków jest równy H
void check_hash(uint32_t M0[16], uint32_t M1[16], uint32_t H_be[4]) {
    unsigned char md5_output[16];
    int i;

    // Obliczenie skrótu MD5 dla dwóch bloków
    compute_md5_two_blocks(M0, M1, md5_output);

    printf("md5_output: ");
    for (i = 0; i < 16; i++) {
        printf("%02x", md5_output[i]);
    }
    printf("\n");

    printf("\nH_be: ");
    for (i = 0; i < 4; i++) {
        printf("%02x", H_be[i]);
    }
    printf("\n");
}

int main() {
    // Dane z tabeli (format big-endian)
    uint32_t M0[16] = {
        0x02dd31d1, 0xc4eee6c5, 0x069a3d69, 0x5cf9af98,
        0x87b5ca2f, 0xab7e4612, 0x3e580440, 0x897ffbb8,
        0x0634ad55, 0x02b3f409, 0x8388e483, 0x5a417125,
        0xe8255108, 0x9fc9cdf7, 0xf2bd1dd9, 0x5b3c3780
    };
    uint32_t M1[16] = {
        0xd11d0b96, 0x9c7b41dc, 0xf497d8e4, 0xd555655a,
        0xc79a7335, 0x0cfdebf0, 0x66f12930, 0x8fb109d1,
        0x797f2775, 0xeb5cd530, 0xbaade822, 0x5c15cc79,
        0xddcb74ed, 0x6dd3c55f, 0xd80a9bb1, 0xe3a7cc35
    };
    uint32_t M0_prime[16] = {
        0x02dd31d1, 0xc4eee6c5, 0x069a3d69, 0x5cf9af98,
        0x07b5ca2f, 0xab7e4612, 0x3e580440, 0x897ffbb8,
        0x0634ad55, 0x02b3f409, 0x8388e483, 0x5a41f125,
        0xe8255108, 0x9fc9cdf7, 0x72bd1dd9, 0x5b3c3780
    };
    uint32_t M1_prime[16] = {
        0xd11d0b96, 0x9c7b41dc, 0xf497d8e4, 0xd555655a,
        0x479a7335, 0x0cfdebf0, 0x66f12930, 0x8fb109d1,
        0x797f2775, 0xeb5cd530, 0xbaade822, 0x5c154c79,
        0xddcb74ed, 0x6dd3c55f, 0x580a9bb1, 0xe3a7cc35
    };
    uint32_t H_be[4] = {
        0xa4c0d35c, 0x95a63a80, 0x5915367d, 0xcfe6b751
    };

    printf("M0 i M1: \n");
    // Sprawdzenie pierwszej instancji
    check_hash(M0, M1, H_be);

    printf("\nM0_prime i M1_prime: \n");
    // Sprawdzenie drugiej instancji
    check_hash(M0_prime, M1_prime, H_be);
  

    return 0;
}
