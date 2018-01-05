/*
 * utils.c
 *
 *      Author: perrin
 */
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

void mat_product_c_float(float *mata, float *matb, float *matc)
{
  uint8_t i,j,k;
  float acc;
  for(i=0;i<4;i++)
  {
    for(j=0;j<4;j++)
    {
      acc=0;
      for(k=0;k<4;k++)
      {
        acc+=mata[i*4+k]*matb[k*4+j];
      }
      matc[i*4+j]=acc;
    }
  }
}

void mat_display_float(float *mat)
{
  uint8_t i,j;
  printf("\r\n");
  for(i=0;i<4;i++)
  {
    for(j=0;j<4;j++)
    {
      printf("%.2f\t",mat[i*4+j]);
    }
    printf("\r\n");
  }
}

void mat_product_c_u8(uint8_t *mata, uint8_t *matb, uint32_t *matc)
{
  uint8_t i,j,k;
  uint8_t acc;
  for(i=0;i<4;i++)
  {
    for(j=0;j<4;j++)
    {
      acc=0;
      for(k=0;k<4;k++)
      {
        acc+=mata[i*4+k]*matb[k*4+j];
      }
      matc[i*4+j]=acc;
    }
  }
}

void mat_display_u8(uint8_t *mat)
{
  uint8_t i,j;
  printf("\r\n");
  for(i=0;i<4;i++)
  {
    for(j=0;j<4;j++)
    {
      printf("%" PRIu8 "\t",mat[i*4+j]);
    }
    printf("\r\n");
  }
}

void mat_display_u32(uint32_t *mat)
{
  uint8_t i,j;
  printf("\r\n");
  for(i=0;i<4;i++)
  {
    for(j=0;j<4;j++)
    {
      printf("%" PRIu32 "\t",mat[i*4+j]);
    }
    printf("\r\n");
  }
}

uint8_t check_output_matrix(uint32_t *matc, uint32_t *matc_ip)
{
  uint8_t i;
  for(i=0;i<16;i++)
  {
    if(matc[i] != matc_ip[i])
    {
      return 0;
    }
  }
  return 1;
}
