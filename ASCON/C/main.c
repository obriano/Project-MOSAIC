#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include<inttypes.h>
#include "ascon.h"
typedef uint64_t bit64;

int main() {
   // initialize nonce, key and IV
   bit64 nonce[2] = { 0x0000000000000001, 0x0000000000000002 };
   bit64 key[2] = { 0 };
   bit64 IV = 0x80400c0600000000;
   bit64 plaintext[] = {0x1234567890abcdef, 0x1234567890abcdef};
   bit64 ciphertext[2] = { 0 };
   bit64 associated_data_text[] = { 0x787878, 0x878787, 0x09090};
bit64 state[5] = {0};
   //encryption
   //initialize state
   state[0] = IV;
   state[1] = key[0];
   state[2] = key[1];
   state[3] = nonce[0];
   state[4] = nonce[1];

 encryption( state,  key,  associated_data_text,  plaintext,  ciphertext);

   //decryption
        
   
   bit64 plaintextdecrypt[10] = { 0 };

   //initialize state
   state[0] = IV;
   state[1] = key[0];
   state[2] = key[1];
   state[3] = nonce[0];
   state[4] = nonce[1];

	decryption( state,  key,  associated_data_text,  plaintextdecrypt,  ciphertext);
}
