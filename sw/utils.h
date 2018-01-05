/*
 * utils.h
 *
 *      Author: perrin
 */
#ifndef __UTILS_H_
#define __UTILS_H_

#define IP_BASEADDR 0x43C00000
#define CSR_OFFSET 0x0
#define MATA_ELEMENT_START_OFFSET 0x08
#define MATB_ELEMENT_START_OFFSET 0x48
#define MATC_ELEMENT_START_OFFSET 0x88

void mat_product_c_u8(uint8_t *mata, uint8_t *matb, uint32_t *matc);
void mat_product_c_float(float *mata, float *matb, float *matc);
void mat_display_u8(uint8_t *mat);
void mat_display_u32(uint32_t *mat);
void mat_display_float(float *mat);

uint8_t check_output_matrix(uint32_t *matc, uint32_t *matc_ip);

#endif
