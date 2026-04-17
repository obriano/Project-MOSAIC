#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include<inttypes.h>
#include "ascon.h"
#include<time.h>
#include<math.h>
typedef uint64_t bit64;

int main() {
  struct timespec start, end;
  double variance, sum, avg, max, min, std;
  max = 0;
  min = 1;
  sum = 0;
  double elapsed_time[1000];
  for(int i = 0; i < 1000; ++i){
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
  clock_gettime(CLOCK_MONOTONIC, &start);
  key_gen(i, state, K_MASTER1, K_MASTER2) ;
  clock_gettime(CLOCK_MONOTONIC, &end);

    long seconds = end.tv_sec - start.tv_sec;
    long nanoseconds = end.tv_nsec - start.tv_nsec;
    double elapsed = seconds + nanoseconds*1e-9;
    if(elapsed > max)
      max = elapsed;
    if(elapsed < min)
      min = elapsed;
    sum += elapsed;
    elapsed_time[i] = elapsed;
  }
  avg = sum/1000;
  for(int i =0; i < 1000; ++i)
    elapsed_time[i] = (elapsed_time[i]-avg)*(elapsed_time[i]-avg);
  for(int i =0; i < 1000; ++i)
    variance += elapsed_time[i];
  variance /= 1000;
    printf("Elapsed time: %.9f seconds\n", avg);
    printf("Min Elapsed time: %.9f seconds\n", min);
    printf("Max Elapsed time: %.9f seconds\n", max);
    printf("Variance: %.90f seconds\n", variance);
  std = sqrt(variance);
    printf("Population STD: %.9f seconds\n", std);
    return 0;
}
