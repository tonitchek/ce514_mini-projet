/*
 * neon.h
 *
 *      Author: perrin
 */
#ifndef __NEON_H_
#define __NEON_H_

int16_t sum_neon(int16_t *tab, uint32_t n);
void mat_product_n1(float *mata, float *matb, float *matc);
void mat_product_n2(float *mata, float *matb, float *matc);
void mat_product_n3(float *matrixA, float *matrixB, float *matrixR);
void mat_product_n4(float *matrixA, float *matrixB, float *matrixR);

#endif
