#include <stdio.h>
#include <stdint.h>

void mat_product_c(uint8_t *mata, uint8_t *matb, uint32_t *matc)
{
  uint8_t i,j,k;
  uint32_t acc;
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

void matc_display(uint32_t *mat)
{
  uint8_t i,j;
  printf("\r\n");
  for(i=0;i<4;i++)
  {
    for(j=0;j<4;j++)
    {
      printf("0x%03x\t",mat[i*4+j]);
    }
    printf("\r\n");
  }
}

uint8_t matc_checker(uint32_t *matc, uint32_t *matc_calc)
{
  uint8_t i,j;
  for(i=0;i<4;i++)
  {
    for(j=0;j<4;j++)
    {
      if(matc[i*4+j] != matc_calc[i*4+j])
      {
	return 0;
      }
    }
  }
  return 1;
}

void matab_display(uint8_t *mat)
{
  uint8_t i,j;
  printf("\r\n");
  for(i=0;i<4;i++)
  {
    for(j=0;j<4;j++)
    {
      printf("0x%01x\t",mat[i*4+j]);
    }
    printf("\r\n");
  }
}

int main(void)
{
  FILE *f;
  uint8_t mata[16];
  uint8_t matb[16];
  uint32_t matc[16];
  uint32_t matc_calc[16];

  f = fopen("matrix.dat","r");
  if(f==NULL)
  {
    printf("Error opening file\n");
  }

  uint8_t i=0,ind;
  //read first matrix A (4 lines)
  fscanf(f,"%x,%x,%x,%x",&mata[0],&mata[1],&mata[2],&mata[3]);
  fscanf(f,"%x,%x,%x,%x",&mata[4],&mata[5],&mata[6],&mata[7]);
  fscanf(f,"%x,%x,%x,%x",&mata[8],&mata[9],&mata[10],&mata[11]);
  fscanf(f,"%x,%x,%x,%x",&mata[12],&mata[13],&mata[14],&mata[15]);

  fscanf(f,"%x,%x,%x,%x",&matb[0],&matb[1],&matb[2],&matb[3]);
  fscanf(f,"%x,%x,%x,%x",&matb[4],&matb[5],&matb[6],&matb[7]);
  fscanf(f,"%x,%x,%x,%x",&matb[8],&matb[9],&matb[10],&matb[11]);
  fscanf(f,"%x,%x,%x,%x",&matb[12],&matb[13],&matb[14],&matb[15]);

  fscanf(f,"%x,%x,%x,%x",&matc[0],&matc[1],&matc[2],&matc[3]);
  fscanf(f,"%x,%x,%x,%x",&matc[4],&matc[5],&matc[6],&matc[7]);
  fscanf(f,"%x,%x,%x,%x",&matc[8],&matc[9],&matc[10],&matc[11]);
  fscanf(f,"%x,%x,%x,%x",&matc[12],&matc[13],&matc[14],&matc[15]);

  matab_display(mata);
  matab_display(matb);

  mat_product_c(mata,matb,matc_calc);

//  printf("\nResult:");
//  matc_display(matc_calc);

  if(!matc_checker(matc,matc_calc))
  {
    printf("!!!MATRIX PRODUCT FAILURE!!!");
    return 1;
  }
  printf("!!!MATRIX PRODUCT SUCCESS!!!");
  
  return 0;
}
