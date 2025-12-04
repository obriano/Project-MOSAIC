#include <stdio.h>
#include "reedsolomon.h"


int main() {
    rs_init();


    // Original 6-byte data
    uint8_t data[RS_K] = {0x0A, 0x14, 0x1E, 0x28, 0x32, 0x3C};
    uint8_t parity[RS_N-RS_K];
    uint8_t block[RS_N];


    printf("Original Data: ");
    for(int i=0;i<RS_K;i++) printf("%02X ", data[i]);
    printf("\n");


    // Encode data to get parity bytes
    rs_encode(data, parity);


    printf("Parity Bytes:  ");
    for(int i=0;i<RS_N-RS_K;i++) printf("%02X ", parity[i]);
    printf("\n");


    // Form transmitted block: data + parity
    for(int i=0;i<RS_K;i++) block[i] = data[i];
    for(int i=0;i<RS_N-RS_K;i++) block[RS_K+i] = parity[i];


    // Introduce 2 errors for testing
    block[7] ^= 0xAA;  // flip some bits of parity byte 7


    printf("Transmitted Block with Errors: ");
    for(int i=0;i<RS_N;i++) printf("%02X ", block[i]);
    printf("\n");


    // Decode RS
    uint8_t corrected[RS_K];
    int errors_corrected = rs_decode(block, corrected);


    printf("Corrected Data: ");
    for(int i=0;i<RS_K;i++) printf("%02X ", corrected[i]);
    printf("\n");


    return 0;
}

