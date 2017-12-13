#include <arm_neon.h>

int16_t sum_neon(int16_t *tab, uint32_t n)
{
	int16_t sum=0;
	int16_t i;
	int16x4_t vec64a, vec64b;
	int16x8_t vec128 = vdupq_n_s16(0);
	int16x8_t temp128;
	for (i=0; i < n; i+=8)
	{
		temp128 = vld1q_s16(&tab[i]);
		vec128 = vaddq_s16(vec128,temp128);
	}
	
	vec64a = vget_low_s16(vec128);
	vec64b = vget_high_s16(vec128);
	vec64a = vadd_s16(vec64a,vec64b);
	
	sum = vget_lane_s16(vec64a,0);
	sum += vget_lane_s16(vec64a,1);
	sum += vget_lane_s16(vec64a,2);
	sum += vget_lane_s16(vec64a,3);
	
	return sum;
}

void mat_product_n1(float *mata, float *matb, float *matc)
{
  //load B matrix with interleaving method: one array v of four
  //vectors val[0], val[1], val[2] and val[3]
  float32x4x4_t matb_neon;
  matb_neon = vld4q_f32(matb);
  uint8_t i,j;
  float32x4_t mata_neon;
  float32x4_t matc_neon;
  float32x2_t matc_neon_acc;
  //loop1 4 iterations
  for(i=0;i<4;i++)
  {
    //load row 0 of A matrix
    mata_neon = vld1q_f32(&mata[i*4]);
    //loop2 4 iterations
    for(j=0;j<4;j++)
    {
      matc_neon = vmulq_f32(mata_neon,matb_neon.val[j]);
      matc_neon_acc = vpadd_f32(vget_high_f32(matc_neon),vget_low_f32(matc_neon));
      matc[i*4+j] = vget_lane_f32(matc_neon_acc,0);
      matc[i*4+j] += vget_lane_f32(matc_neon_acc,1);
    }
    //end loop2
  }
  //end loop1
}

void mat_product_n2(float *mata, float *matb, float *matc)
{
  //load columns of A matrix with interleaving method: one array
  //mata_cols_neon of four vectors val[0], val[1], val[2] and val[3]
  float32x4x4_t mata_cols_neon = vld4q_f32(mata);

  //vector for columns of matrix C from MAC result
  float32x4x4_t matc_cols_neon;
  matc_cols_neon.val[0] = vdupq_n_f32(0.0);
  matc_cols_neon.val[1] = vdupq_n_f32(0.0);
  matc_cols_neon.val[2] = vdupq_n_f32(0.0);
  matc_cols_neon.val[3] = vdupq_n_f32(0.0);

//  float32x4_t matb_elem_neon;
//  uint8_t i,j;
//  for(i=0;i<4;i++)
//  {
//    for(j=0;j<4;j++)
//    {
//      matb_elem_neon = vdupq_n_f32(matb[j*4+i]);
//      matc_cols_neon.val[i] = vmlaq_f32(matc_cols_neon.val[i],mata_cols_neon.val[i],matb_elem_neon);
//    }
//  }

  float32x4_t matb_elem_neon = vdupq_n_f32(matb[0]);
  matc_cols_neon.val[0] = vmlaq_f32(matc_cols_neon.val[0],mata_cols_neon.val[0],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[4]);
  matc_cols_neon.val[0] = vmlaq_f32(matc_cols_neon.val[0],mata_cols_neon.val[1],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[8]);
  matc_cols_neon.val[0] = vmlaq_f32(matc_cols_neon.val[0],mata_cols_neon.val[2],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[12]);
  matc_cols_neon.val[0] = vmlaq_f32(matc_cols_neon.val[0],mata_cols_neon.val[3],matb_elem_neon);

  matb_elem_neon = vdupq_n_f32(matb[1]);
  matc_cols_neon.val[1] = vmlaq_f32(matc_cols_neon.val[1],mata_cols_neon.val[0],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[5]);
  matc_cols_neon.val[1] = vmlaq_f32(matc_cols_neon.val[1],mata_cols_neon.val[1],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[9]);
  matc_cols_neon.val[1] = vmlaq_f32(matc_cols_neon.val[1],mata_cols_neon.val[2],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[13]);
  matc_cols_neon.val[1] = vmlaq_f32(matc_cols_neon.val[1],mata_cols_neon.val[3],matb_elem_neon);

  matb_elem_neon = vdupq_n_f32(matb[2]);
  matc_cols_neon.val[2] = vmlaq_f32(matc_cols_neon.val[2],mata_cols_neon.val[0],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[6]);
  matc_cols_neon.val[2] = vmlaq_f32(matc_cols_neon.val[2],mata_cols_neon.val[1],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[10]);
  matc_cols_neon.val[2] = vmlaq_f32(matc_cols_neon.val[2],mata_cols_neon.val[2],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[14]);
  matc_cols_neon.val[2] = vmlaq_f32(matc_cols_neon.val[2],mata_cols_neon.val[3],matb_elem_neon);

  matb_elem_neon = vdupq_n_f32(matb[3]);
  matc_cols_neon.val[3] = vmlaq_f32(matc_cols_neon.val[3],mata_cols_neon.val[0],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[7]);
  matc_cols_neon.val[3] = vmlaq_f32(matc_cols_neon.val[3],mata_cols_neon.val[1],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[11]);
  matc_cols_neon.val[3] = vmlaq_f32(matc_cols_neon.val[3],mata_cols_neon.val[2],matb_elem_neon);
  matb_elem_neon = vdupq_n_f32(matb[15]);
  matc_cols_neon.val[3] = vmlaq_f32(matc_cols_neon.val[3],mata_cols_neon.val[3],matb_elem_neon);

  vst4q_f32(matc,matc_cols_neon);
}

void mat_product_n3(float *matrixA, float *matrixB, float *matrixR)
{
  float32x4_t b, a0, a1, a2, a3, r;
  a0 = vld1q_f32(matrixA);      /* col 0 of matrixA */
  a1 = vld1q_f32(matrixA + 4);  /* col 1 of matrixA */
  a2 = vld1q_f32(matrixA + 8);  /* col 2 of matrixA */
  a3 = vld1q_f32(matrixA + 12); /* col 3 of matrixA */
  b = vld1q_f32(matrixB);
  /* load col 0 of matrixB */
  r = vmulq_lane_f32(a0, vget_low_f32(b), 0);
  r = vmlaq_lane_f32(r, a1, vget_low_f32(b), 1);
  r = vmlaq_lane_f32(r, a2, vget_high_f32(b), 0);
  r = vmlaq_lane_f32(r, a3, vget_high_f32(b), 1);
  vst1q_f32(matrixR, r);
  /* store col 0 of result */
  b = vld1q_f32(matrixB + 4); /* load col 1 of matrixB */
  r = vmulq_lane_f32(a0, vget_low_f32(b), 0);
  r = vmlaq_lane_f32(r, a1, vget_low_f32(b), 1);
  r = vmlaq_lane_f32(r, a2, vget_high_f32(b), 0);
  r = vmlaq_lane_f32(r, a3, vget_high_f32(b), 1);
  vst1q_f32(matrixR + 4, r);
  /* store col 1 of result */
  b = vld1q_f32(matrixB + 8); /* load col 2 of matrixB */
  r = vmulq_lane_f32(a0, vget_low_f32(b), 0);
  r = vmlaq_lane_f32(r, a1, vget_low_f32(b), 1);
  r = vmlaq_lane_f32(r, a2, vget_high_f32(b), 0);
  r = vmlaq_lane_f32(r, a3, vget_high_f32(b), 1);
  vst1q_f32(matrixR + 8, r);
  /* store col 2 of result */
  b = vld1q_f32(matrixB + 12); /* load col 3 of matrixB */
  r = vmulq_lane_f32(a0, vget_low_f32(b), 0);
  r = vmlaq_lane_f32(r, a1, vget_low_f32(b), 1);
  r = vmlaq_lane_f32(r, a2, vget_high_f32(b), 0);
  r = vmlaq_lane_f32(r, a3, vget_high_f32(b), 1);
  vst1q_f32(matrixR + 12, r);
  /* store col 3 of result */
}

/*
void mat_product_n4(float *matrixA, float *matrixB, float *matrixR)
{
  __asm__(
    "vld1.32 {d0-d3}, [r1]!"
    "vld1.32 {d4-d7}, [r1]!"
    "vld1.32 {d8-d11}, [r2]!"
    "vld1.32 {d12-d15}, [r2]!");
}
*/
