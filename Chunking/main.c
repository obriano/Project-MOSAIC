#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "chunking_reconstruction.h"

int main(){

    printf("==== Chunking ====\n");
    uint64_t cipherText[2]  = {13298456812977459382, 6309475283011774491};
    // 10111000_10001101_10011100_00000011_01011110_01100101_00010000_10110110
    // 01010111_10001111_11000010_01010111_01000011_00000110_00101000_00011011
    uint64_t nonce[2]       = {10438599628419377451, 15930482291758040332};
    // 10010000_11011101_01011011_00001110_01010100_01110110_00101001_00101011
    // 11011101_00010100_01110001_00111101_10110100_11100011_10000101_00001100
    uint64_t authTag[2]     = {4122849982713300449, 7253194762984410227};
    // 00111001_00110111_01001110_00110111_00101001_11011010_00000101_11100001
    // 01100100_10101000_10000110_00110101_00110110_01101000_11001100_01110011
    uint64_t chunks[8];

    chunking(cipherText, nonce, authTag, chunks);
    for (int i = 0; i < sizeof(chunks)/sizeof(chunks[0]); ++i){
        printf("%lu\n", chunks[i]);
    }
    

    uint64_t cipherReconstructed[2];
    uint64_t nonceReconstructed[2];
    uint64_t authTagReconstructed[2];

    printf("==== Reconstruction ====\n");

    reconstruction(chunks, cipherReconstructed, nonceReconstructed, authTagReconstructed);

    for (int i = 0; i < sizeof(cipherReconstructed)/sizeof(cipherReconstructed[0]); ++i){
        printf("%lu\n", cipherReconstructed[i]);
    }
    for (int i = 0; i < sizeof(nonceReconstructed)/sizeof(nonceReconstructed[0]); ++i){
        printf("%lu\n", nonceReconstructed[i]);
    }
    for (int i = 0; i < sizeof(authTagReconstructed)/sizeof(authTagReconstructed[0]); ++i){
        printf("%lu\n", authTagReconstructed[i]);
    }
}