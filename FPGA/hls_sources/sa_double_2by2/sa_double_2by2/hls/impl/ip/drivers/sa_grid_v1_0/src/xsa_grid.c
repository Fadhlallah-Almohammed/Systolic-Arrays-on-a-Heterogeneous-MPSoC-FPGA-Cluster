// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.2 (64-bit)
// Tool Version Limit: 2024.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xsa_grid.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XSa_grid_CfgInitialize(XSa_grid *InstancePtr, XSa_grid_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XSa_grid_Start(XSa_grid *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XSa_grid_ReadReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_AP_CTRL) & 0x80;
    XSa_grid_WriteReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XSa_grid_IsDone(XSa_grid *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XSa_grid_ReadReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XSa_grid_IsIdle(XSa_grid *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XSa_grid_ReadReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XSa_grid_IsReady(XSa_grid *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XSa_grid_ReadReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XSa_grid_EnableAutoRestart(XSa_grid *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XSa_grid_WriteReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XSa_grid_DisableAutoRestart(XSa_grid *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XSa_grid_WriteReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_AP_CTRL, 0);
}

void XSa_grid_InterruptGlobalEnable(XSa_grid *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XSa_grid_WriteReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_GIE, 1);
}

void XSa_grid_InterruptGlobalDisable(XSa_grid *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XSa_grid_WriteReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_GIE, 0);
}

void XSa_grid_InterruptEnable(XSa_grid *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XSa_grid_ReadReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_IER);
    XSa_grid_WriteReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_IER, Register | Mask);
}

void XSa_grid_InterruptDisable(XSa_grid *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XSa_grid_ReadReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_IER);
    XSa_grid_WriteReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_IER, Register & (~Mask));
}

void XSa_grid_InterruptClear(XSa_grid *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XSa_grid_WriteReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_ISR, Mask);
}

u32 XSa_grid_InterruptGetEnabled(XSa_grid *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XSa_grid_ReadReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_IER);
}

u32 XSa_grid_InterruptGetStatus(XSa_grid *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XSa_grid_ReadReg(InstancePtr->Control_BaseAddress, XSA_GRID_CONTROL_ADDR_ISR);
}

