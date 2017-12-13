/*
 * m4x4_multiplier.c
 *
 *      Author: perrin
 */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <inttypes.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include "neon.h"
#include "utils.h"

#define PAGE_SIZE ((size_t)getpagesize())

void help(char *name)
{
  fprintf(stderr,
	  "== Tool for M4x4_MULTIPLIER IP ==\n\n");
  fprintf(stderr,"Usage: %s [options] <args>\n",name);
  fprintf(stderr,"[options] are:\n");
  fprintf(stderr,"-h to print this help\n");
  fprintf(stderr,"-i to manually enter input matrices\n");
  fprintf(stderr,"-f<filepath> to give file path containing input matrices\n");
  fprintf(stderr,"-t to run full test (tb_matrix.dat file must be present)\n");
  exit(1);
}

int main(int ac, char** av)
{
  int c;
  uint8_t interactive_mode = 0;
  uint8_t file_mode = 0;
  uint8_t test_mode = 0;
  uint8_t performance = 0;
  char filename[128]; //for absolute path
  FILE *f;

  printf("\r\n== M4x4 MULTIPLIER 1.0 ==\n");
  
  while ((c = getopt (ac, av, "hif:tP")) != -1)
  {
    switch(c)
    {
    case 'i':
      interactive_mode = 1;
      break;
    case 'f':
      sscanf(optarg, "%s", filename);
      file_mode = 1;
      break;
    case 't':
      test_mode = 1;
      break;
    case 'P':
      performance = 1;
      break;
    case 'h':
      help(av[0]);
      break;
    default:
      help(av[0]);
    }
  }

  //mmap base address
  int fd = open("/dev/mem", O_RDWR|O_SYNC);
  if (fd < 0)
  {
    printf("open(/dev/mem) failed\n");
  }
  volatile uint8_t *mm = (volatile uint8_t*)mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, IP_BASEADDR);
  if (mm == MAP_FAILED)
  {
    printf("mmap failed\n");
  }

  if(interactive_mode)
  {
    printf("Not yet implemented\n");
  }

  if(file_mode)
  {
    printf("Not yet implemented\n");
  }
  
  if(test_mode)
  {
    printf("Test mode\n");
    f = fopen("tb_matrix.dat","r");
    if(f==NULL)
    {
      fprintf(stderr,"Error opening file\n");
      munmap((void *)mm, PAGE_SIZE);
      close(fd);
      return 1;
    }
    uint8_t mata[16];
    uint8_t matb[16];
    uint32_t matc[16];
    uint32_t matc_ip[16];
    //read matrix A
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&mata[0],&mata[1],&mata[2],&mata[3]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&mata[4],&mata[5],&mata[6],&mata[7]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&mata[8],&mata[9],&mata[10],&mata[11]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&mata[12],&mata[13],&mata[14],&mata[15]);
    //read matrix B
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&matb[0],&matb[1],&matb[2],&matb[3]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&matb[4],&matb[5],&matb[6],&matb[7]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&matb[8],&matb[9],&matb[10],&matb[11]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&matb[12],&matb[13],&matb[14],&matb[15]);
    //read matrix C
    fscanf(f,"%" SCNu32 "\t%" SCNu32 "\t%" SCNu32 "\t%" SCNu32 "",&matc[0],&matc[1],&matc[2],&matc[3]);
    fscanf(f,"%" SCNu32 "\t%" SCNu32 "\t%" SCNu32 "\t%" SCNu32 "",&matc[4],&matc[5],&matc[6],&matc[7]);
    fscanf(f,"%" SCNu32 "\t%" SCNu32 "\t%" SCNu32 "\t%" SCNu32 "",&matc[8],&matc[9],&matc[10],&matc[11]);
    fscanf(f,"%" SCNu32 "\t%" SCNu32 "\t%" SCNu32 "\t%" SCNu32 "",&matc[12],&matc[13],&matc[14],&matc[15]);
    fclose(f);
    mat_display_u8(mata);
    mat_display_u8(matb);
    //load matrix A (row by row)
    uint8_t i;
    for(i=0;i<16;i++)
    {
      *(volatile uint32_t*)(mm + MATA_ELEMENT_START_OFFSET+(i*4)) = (uint32_t)mata[i];
    }
    //load matrix B (column by column)
    uint8_t j,k=0;
    for(i=0;i<4;i++)
    {
      for(j=0;j<4;j++)
      {
        *(volatile uint32_t*)(mm + MATB_ELEMENT_START_OFFSET+(k*4)) = (uint32_t)matb[i+j*4];
        k++;
      }
    }
    //start IP calcul
    *(volatile uint32_t*)(mm + CSR_OFFSET) = (uint32_t)0x1;
    //store matrix C
    for(i=0;i<16;i++)
    {
      matc_ip[i] = *(volatile uint32_t*)(mm + MATC_ELEMENT_START_OFFSET+(i*4));
    }
    //display output matrix
    mat_display_u32(matc_ip);
    //compare matrix
    if(!check_output_matrix(matc,matc_ip))
    {
      printf("!!!Unit Test FAILURE!!!\r\n");
      munmap((void *)mm, PAGE_SIZE);
      close(fd);
      return 1;
    }
    printf("+++Unit Test SUCCESS+++\r\n");

    printf("\r\nSet the SW0 switch to HIGH level and press any key\n");
    char key;
    scanf("%c",&key);
    *(volatile uint32_t*)(mm + MATA_ELEMENT_START_OFFSET+0xC) = (uint32_t)254;
    //store matrix A
    for(i=0;i<16;i++)
    {
      mata[i] = *(volatile uint32_t*)(mm + MATA_ELEMENT_START_OFFSET+(i*4));
    }
    mat_display_u8(mata);
    mat_display_u8(matb);
    //start IP calcul
    *(volatile uint32_t*)(mm + CSR_OFFSET) = (uint32_t)0x1;
    //store matrix C
    for(i=0;i<16;i++)
    {
      matc_ip[i] = *(volatile uint32_t*)(mm + MATC_ELEMENT_START_OFFSET+(i*4));
    }
    //display output matrix
    mat_display_u32(matc_ip);
    //compare matrix
    if(!check_output_matrix(matc,matc_ip))
    {
      printf("!!!Unit Test FAILURE!!!\r\n");
      munmap((void *)mm, PAGE_SIZE);
      close(fd);
      return 1;
    }
    printf("+++Unit Test SUCCESS+++\r\n");    
  }

  if(performance)
  {
    printf("Not yet implemented\n");
/*    f = fopen("tb_matrix.dat","r");
    if(f==NULL)
    {
      fprintf(stderr,"Error opening file\n");
      munmap((void *)mm, PAGE_SIZE);
      close(fd);
      return 1;
    }
    uint8_t mata[16];
    uint8_t matb[16];
    uint32_t matc[16];
    //read matrix B
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&mata[0],&mata[1],&mata[2],&mata[3]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&mata[4],&mata[5],&mata[6],&mata[7]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&mata[8],&mata[9],&mata[10],&mata[11]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&mata[12],&mata[13],&mata[14],&mata[15]);
    //read matrix B    
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&matb[0],&matb[1],&matb[2],&matb[3]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&matb[4],&matb[5],&matb[6],&matb[7]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&matb[8],&matb[9],&matb[10],&matb[11]);
    fscanf(f,"%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "\t%" SCNu8 "",&matb[12],&matb[13],&matb[14],&matb[15]);
    fclose(f);
    mat_display_u8(mata);
    mat_display_u8(matb);
    //get time overhead
    struct timespec begin, end;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&begin);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&end);
    long overhead = end.tv_nsec-begin.tv_nsec;
    printf("Time overhead: %ld\n",overhead);
    //measure execution time for computation with Cortex A9
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&begin);
    mat_product_c_u8(mata,matb,matc);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&end);
    printf("CPU time execution: %ld\n",end.tv_nsec-begin.tv_nsec);
    //measure execution time for computation with NEON
    float mata_f[16];
    float matb_f[16];
    float matc_f[16];
    u8_2_float(mata,mata_f);
    u8_2_float(matb,matb_f);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&begin);
    mat_product_n3(mata_f,matb_f,matc_f);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&end);
    mat_display_float(matc_f);
    printf("NEON time execution: %ld\n",end.tv_nsec-begin.tv_nsec);
    //measure execution time for computation with IP
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&begin);
    //load matrix A (row by row)
    uint8_t i;
    for(i=0;i<16;i++)
    {
      *(volatile uint32_t*)(mm + MATA_ELEMENT_START_OFFSET+(i*4)) = (uint32_t)mata[i];
    }
    //load matrix B (column by column)
    uint8_t j,k=0;
    for(i=0;i<4;i++)
    {
      for(j=0;j<4;j++)
      {
        *(volatile uint32_t*)(mm + MATB_ELEMENT_START_OFFSET+(k*4)) = (uint32_t)matb[i+j*4];
        k++;
      }
    }
    //start IP calcul
    *(volatile uint32_t*)(mm + CSR_OFFSET) = (uint32_t)0x1;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&end);
    //store matrix C
    for(i=0;i<16;i++)
    {
      matc[i] = *(volatile uint32_t*)(mm + MATC_ELEMENT_START_OFFSET+(i*4));
    }
    //display output matrix
    mat_display_u32(matc);
    printf("IP time execution: %ld\n",end.tv_nsec-begin.tv_nsec);
*/
  }

  munmap((void *)mm, PAGE_SIZE);
  close(fd);

  return 0;
}
