/* MTI_DPI */

/*
 * Copyright 2002-2019 Mentor Graphics Corporation.
 *
 * Note:
 *   This file is automatically generated.
 *   Please do not edit this file - you will lose your edits.
 *
 * Settings when this file was generated:
 *   PLATFORM = 'linux_x86_64'
 */
#ifndef INCLUDED_DPIHEADER
#define INCLUDED_DPIHEADER

#ifdef __cplusplus
#define DPI_LINK_DECL  extern "C" 
#else
#define DPI_LINK_DECL 
#endif

#include "svdpi.h"



DPI_LINK_DECL DPI_DLLESPEC
int
dyn_pre_gen_wrapper(
    int sys_bw,
    int pkt_bw,
    int format,
    int gamma_rot,
    int subband_punct,
    int chain_tx,
    int n_4ch);

#endif 