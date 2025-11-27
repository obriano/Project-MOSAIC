#include <stdint.h>
#ifndef CHUNKING_RECONSTRUCTION_H
#define CHUNKING_RECONSTRUCTION_H
void chunking(uint64_t cipherText[2], uint64_t nonce[2], uint64_t authenticationTag[2], uint64_t chunks[8]);
void reconstruction(uint64_t chunks[8], uint64_t cipherText[2], uint64_t nonce[2], uint64_t authenticationTag[2]);
#endif