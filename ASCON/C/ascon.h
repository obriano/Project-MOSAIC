#ifndef ASCON_H
#define ASCON_H
typedef uint64_t bit64;
bit64 print_state(bit64 state[5]);
bit64 rotate(bit64 state,  int l);
void add_constant(bit64 state[5],  int i,  int a);
void sbox(bit64 x[5]);
void linear(bit64 state[5]);
void p(bit64 state[5],  int a);
void initialization(bit64 state[5], bit64 key[2]);
void associated_data(bit64 state[5],  int length, bit64 associated_data_text[]);
void finalization(bit64 state[5], bit64 key[2]);
void encrypt(bit64 state[5], int length,bit64 plaintext[], bit64 ciphertext[]);
void decrypt(bit64 state[5], int length,bit64 plaintext[], bit64 ciphertext[]);
void encryption (bit64 state[5], bit64 key[2], bit64 associated_data_text[3], bit64 plaintext[2], bit64 ciphertext[2]);
void decryption (bit64 state[5], bit64 key[2], bit64 associated_data_text[3], bit64 plaintextdecrypt[2], bit64 ciphertextdecrypt[2]);
void key_gen(bit64 uptime, bit64 state[5], bit64 K_MASTER1, bit64 K_MASTER2);
#endif
