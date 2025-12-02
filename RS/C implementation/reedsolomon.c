#include "reedsolomon.h"
#include <stdio.h>
#include <string.h>


#define GF_SIZE 256
#define PRIMITIVE 0x11d  // x^8 + x^4 + x^3 + x^2 + 1


// GF(2^8) tables
static uint8_t gf_exp[2*GF_SIZE];  // exponential table
static uint8_t gf_log[GF_SIZE];    // log table


static uint8_t generator[RS_N-RS_K+1]; // generator polynomial


static uint8_t gf_mul(uint8_t a, uint8_t b);
static uint8_t gf_div(uint8_t a, uint8_t b);
static uint8_t gf_pow(uint8_t a, int power);


// Initialize GF(2^8) and generator polynomial
void rs_init() {
    int i;
    uint8_t x = 1;
    for(i=0;i<GF_SIZE;i++){
        gf_exp[i] = x;
        gf_log[x] = i;
        x <<= 1;
        if(x & 0x100) x ^= PRIMITIVE;
    }
    for(i=GF_SIZE;i<2*GF_SIZE;i++) gf_exp[i] = gf_exp[i-GF_SIZE];


    // Build generator polynomial g(x) = (x - α^1)...(x - α^t)
    generator[0] = 1;
    for(i=1;i<=RS_N-RS_K;i++) generator[i] = 0;


    for(i=0;i<RS_N-RS_K;i++){
        uint8_t coef[RS_N-RS_K+1] = {0};
        coef[0] = 1;
        uint8_t root = gf_exp[i]; // α^i
        for(int j=RS_N-RS_K;j>0;j--){
            coef[j] = coef[j] ^ gf_mul(generator[j-1], root);
        }
        for(int j=0;j<=RS_N-RS_K;j++) generator[j] = coef[j];
    }
}


// GF(2^8) multiplication
static uint8_t gf_mul(uint8_t a, uint8_t b){
    if(a==0 || b==0) return 0;
    int sum = gf_log[a]+gf_log[b];
    return gf_exp[sum % 255];
}


// GF(2^8) division
static uint8_t gf_div(uint8_t a, uint8_t b){
    if(a==0) return 0;
    if(b==0) return 0; // error
    int diff = gf_log[a]-gf_log[b];
    if(diff<0) diff+=255;
    return gf_exp[diff];
}


// GF(2^8) power
static uint8_t gf_pow(uint8_t a, int power){
    if(power==0) return 1;
    if(a==0) return 0;
    int log_result = (gf_log[a]*power) % 255;
    if(log_result<0) log_result+=255;
    return gf_exp[log_result];
}


// RS Encode: 6 data bytes -> 6 parity bytes
void rs_encode(uint8_t data[RS_K], uint8_t parity[RS_N-RS_K]){
    memset(parity,0,RS_N-RS_K);
    for(int i=0;i<RS_K;i++){
        uint8_t feedback = data[i]^parity[0];
        for(int j=0;j<RS_N-RS_K-1;j++)
            parity[j] = parity[j+1]^gf_mul(feedback,generator[RS_N-RS_K-j-1]);
        parity[RS_N-RS_K-1] = gf_mul(feedback,generator[0]);
    }
}


// RS Decode: detects and corrects simple errors (simplified)
int rs_decode(uint8_t received[RS_N], uint8_t corrected[RS_K]){
    uint8_t synd[RS_N-RS_K];
    int error = 0;


    // Compute syndromes
    for(int i=0;i<RS_N-RS_K;i++){
        synd[i] = 0;
        for(int j=0;j<RS_N;j++){
            synd[i] ^= gf_mul(received[j], gf_pow(2, i*j));
        }
        if(synd[i] != 0) error = 1;
    }


    if(!error){
        for(int i=0;i<RS_K;i++) corrected[i]=received[i];
        return 0; // no errors
    }


    // Brute-force error location (simplified)
    uint8_t loc[RS_N] = {0};
    for(int i=0;i<RS_N;i++){
        uint8_t sum=0;
        for(int j=0;j<RS_N-RS_K;j++){
            sum ^= gf_mul(synd[j], gf_pow(gf_exp[i], j));
        }
        if(sum==0) loc[i]=1; // error at position i
    }


    // Correct errors (assume magnitude = 1 for demo)
    for(int i=0;i<RS_N;i++){
        if(loc[i]) received[i] ^= 1;
    }


    for(int i=0;i<RS_K;i++) corrected[i] = received[i];
    return 1; // errors corrected
}
