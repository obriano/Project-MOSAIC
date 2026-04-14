#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include<inttypes.h>
#include "ascon.h"
typedef uint64_t bit64;

int key_gen() {
   // initialize nonce, key and IV
   bit64 nonce[2] = { 0x0000000000000001, 0x0000000000000002 };
   bit64 key[2] = { 0 };
   bit64 IV = 0x0000080100cc0002;
   bit64 plaintext[] = {0x1234567890abcdef, 0x1234567890abcdef};
   bit64 ciphertext[2] = { 0 };
   bit64 associated_data_text[] = { 0x787878, 0x878787, 0x09090};
   bit64 state[5] = {0};
    state[0] = IV;
       // Long-term master key
    bit64 K_MASTER1 = 0xDEADBEEF00112233;
    bit64 K_MASTER2 = 0x445566778899AABB;
   
    //bit64 HASH_IV = 0x0000080100cc0002;
    bit64 uptime = 66;
    p(&state[0], 12);
    state[0] ^= K_MASTER1;
    p(&state[0], 12);
    state[0] ^= K_MASTER2;
    p(&state[0], 12);
    state[0] ^= uptime;
    p(&state[0], 12);
     printf("%llx %llx\n", state[1], state[0]);
}
