#include <stdint.h>
#include <stdio.h>

void chunking(uint64_t cipherText[2], uint64_t nonce[2], uint64_t authenticationTag[2], uint64_t chunks[8]){
    int counter = 0;
    for (int i = 0; i < 2; ++i){
        for (int j = 0; j < 4; ++j){
            uint16_t cipherNibble = (cipherText[i] >> (j * 16)) & 0xFFFF;
            //printf("cipherNibble %d: %d\n", counter, cipherNibble);
            uint16_t nonceNibble = (nonce[i] >> (j * 16)) & 0xFFFF;
            //printf("nonceNibble %d: %d\n", counter, nonceNibble);
            uint16_t authTagNibble = (authenticationTag[i] >> (j * 16)) & 0xFFFF;
            //printf("authTagNibble %d: %d\n", counter, authTagNibble);

            //printf("%d\n", cipherNibble);


            uint64_t chunk =
                ((uint64_t)cipherNibble << 32) |
                ((uint64_t)nonceNibble  << 16) |
                ((uint64_t)authTagNibble);

            chunks[counter] = chunk;
            ++counter;
        }
    }
    //printf("%lu",chunks[0]);
}

void reconstruction(uint64_t chunks[8], uint64_t cipherText[2], uint64_t nonce[2], uint64_t authenticationTag[2]){

    int counter = 0;
    for (int i = 0; i < 2; ++i) {
        for (int j = 0; j < 4; ++j) {

            uint64_t chunk = chunks[counter++];

            // Extract the 3×16-bit fields
            uint16_t cipherNibble = (chunk >> 32) & 0xFFFF;
            uint16_t nonceNibble  = (chunk >> 16) & 0xFFFF;
            uint16_t authNibble   =  chunk        & 0xFFFF;

            // Insert back into the 64-bit values
            cipherText[i] |= ((uint64_t)cipherNibble << (j * 16));
            nonce[i]      |= ((uint64_t)nonceNibble  << (j * 16));
            authenticationTag[i] |= ((uint64_t)authNibble << (j * 16));
        }
    }
}
