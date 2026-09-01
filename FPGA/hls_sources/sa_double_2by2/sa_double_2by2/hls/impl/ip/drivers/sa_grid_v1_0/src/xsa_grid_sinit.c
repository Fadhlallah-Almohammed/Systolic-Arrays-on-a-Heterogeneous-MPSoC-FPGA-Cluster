// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.2 (64-bit)
// Tool Version Limit: 2024.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#ifdef SDT
#include "xparameters.h"
#endif
#include "xsa_grid.h"

extern XSa_grid_Config XSa_grid_ConfigTable[];

#ifdef SDT
XSa_grid_Config *XSa_grid_LookupConfig(UINTPTR BaseAddress) {
	XSa_grid_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XSa_grid_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XSa_grid_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XSa_grid_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XSa_grid_Initialize(XSa_grid *InstancePtr, UINTPTR BaseAddress) {
	XSa_grid_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XSa_grid_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XSa_grid_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XSa_grid_Config *XSa_grid_LookupConfig(u16 DeviceId) {
	XSa_grid_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XSA_GRID_NUM_INSTANCES; Index++) {
		if (XSa_grid_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XSa_grid_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XSa_grid_Initialize(XSa_grid *InstancePtr, u16 DeviceId) {
	XSa_grid_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XSa_grid_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XSa_grid_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

