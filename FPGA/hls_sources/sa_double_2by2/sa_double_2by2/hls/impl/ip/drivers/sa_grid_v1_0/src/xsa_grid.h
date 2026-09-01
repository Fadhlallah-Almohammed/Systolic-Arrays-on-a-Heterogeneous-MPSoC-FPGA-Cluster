// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.2 (64-bit)
// Tool Version Limit: 2024.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XSA_GRID_H
#define XSA_GRID_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xsa_grid_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
#ifdef SDT
    char *Name;
#else
    u16 DeviceId;
#endif
    u64 Control_BaseAddress;
} XSa_grid_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XSa_grid;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XSa_grid_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XSa_grid_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XSa_grid_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XSa_grid_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
#ifdef SDT
int XSa_grid_Initialize(XSa_grid *InstancePtr, UINTPTR BaseAddress);
XSa_grid_Config* XSa_grid_LookupConfig(UINTPTR BaseAddress);
#else
int XSa_grid_Initialize(XSa_grid *InstancePtr, u16 DeviceId);
XSa_grid_Config* XSa_grid_LookupConfig(u16 DeviceId);
#endif
int XSa_grid_CfgInitialize(XSa_grid *InstancePtr, XSa_grid_Config *ConfigPtr);
#else
int XSa_grid_Initialize(XSa_grid *InstancePtr, const char* InstanceName);
int XSa_grid_Release(XSa_grid *InstancePtr);
#endif

void XSa_grid_Start(XSa_grid *InstancePtr);
u32 XSa_grid_IsDone(XSa_grid *InstancePtr);
u32 XSa_grid_IsIdle(XSa_grid *InstancePtr);
u32 XSa_grid_IsReady(XSa_grid *InstancePtr);
void XSa_grid_EnableAutoRestart(XSa_grid *InstancePtr);
void XSa_grid_DisableAutoRestart(XSa_grid *InstancePtr);


void XSa_grid_InterruptGlobalEnable(XSa_grid *InstancePtr);
void XSa_grid_InterruptGlobalDisable(XSa_grid *InstancePtr);
void XSa_grid_InterruptEnable(XSa_grid *InstancePtr, u32 Mask);
void XSa_grid_InterruptDisable(XSa_grid *InstancePtr, u32 Mask);
void XSa_grid_InterruptClear(XSa_grid *InstancePtr, u32 Mask);
u32 XSa_grid_InterruptGetEnabled(XSa_grid *InstancePtr);
u32 XSa_grid_InterruptGetStatus(XSa_grid *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
