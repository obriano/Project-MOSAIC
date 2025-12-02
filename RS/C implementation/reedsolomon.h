#ifndef REEDSOLMON_H
#define REEDSOLMON_H


#include <stdint.h>


#define RS_N 12       // total symbols (6 data + 6 parity)
#define RS_K 6        // data symbols
#define RS_T 3        // max correctable symbols


void rs_init();  // initialize GF tables
void rs_encode(uint8_t data[RS_K], uint8_t parity[RS_N-RS_K]);
int  rs_decode(uint8_t received[RS_N], uint8_t corrected[RS_K]);


#endif