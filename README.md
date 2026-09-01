# Systolic Arrays on an MPSoC-FPGA Cluster

## Project description

Deploying scientific computing workloads on a single FPGA often encounters
severe memory and resource bottlenecks, limiting both performance and
scalability. To address these constraints, this project explores a heterogeneous
architecture based on a cluster of FPGA-based Multi-Processor System-on-Chip
(MPSoC) devices to accelerate large-scale matrix multiplication using systolic
arrays. The methodology emphasizes efficient workload partitioning across
multiple heterogeneous nodes and systematically compares two communication
paradigms: interconnection through the Processing System (PS) using a standard
Ethernet stack, and ultra-low-latency hardware-level interconnection through the
Programmable Logic (PL) using high-performance interfaces. The study will
quantitatively evaluate how network topology affects bandwidth utilization,
latency, and data starvation in distributed spatial computing environments. It
will also investigate the distribution of computation across CPUs, GPUs, and
FPGAs, analyzing the advantages and disadvantages of each architecture for
scientific computing workloads. The results are expected to provide practical
insights and design guidelines for efficiently scaling scientific computing
workloads on FPGA clusters, improving throughput, energy efficiency, and
real-time performance for large-scale matrix operations.

See the Status section below for what was implemented and measured within the
duration of the internship.

---

## Before anything else: cluster access

**None of the notebooks in this repository run on a local machine.**

The HyperFPGA cluster is hosted at ICTP and is not publicly reachable. All three
notebooks reserve physical nodes, program bitstreams onto them and drive them
over `ipyparallel` engines that live on the boards themselves. They therefore
require:

- An account on the ICTP JupyterHub instance that fronts the cluster
- Access to that instance from inside the institute network, or through the
  approved remote access route
- A kernel with `hyperfpga_cluster`, `hyperfpga_comutils` and `ipyparallel`
  installed, which the hub provides
- Free `4ge21` nodes at the time of the run, one for the single-node design and
  four specific cabled nodes for the Aurora design

The Vivado and Vitis HLS parts of this repository do build on any local machine
with the correct tool versions. Only the execution requires the cluster.

---

## Contents

```
fpga/
  hls/
    sa_grid.cpp               the systolic block
    sa_grid.h
    tb_sa_grid.cpp            test bench
    hls_config.cfg            part, clock and top function settings
    vitis-comp.json
    sa_double_2by2/           the same block packaged as an IP
  vivado/
    sa_q4/                    single-node grid, Vivado project
      sa_q4.xpr
      sa_q4.srcs/             block design and constraints
      sa_q4.hw/
      sa_q4_ILA2.xsa          exported hardware, ready to program
    sa_grid_2x2_aurora/       four-node Aurora design, Hog repository
      BD/                     block design Tcl
      BSP/                    board definition
      Const/                  GTH constraints
      HW/                     exported hardware, ready to program
        sa_q4_top_wrapper_v_0_0_2.xsa
        bitstream/
      IP/                     Aurora IP and the packaged HLS IP
      Top/                    Hog project and list files
      VHDL/                   RTL sources
      Hog/                    Hog framework, git submodule
  notebooks/
    sa_grid_host.ipynb        runs the single-node grid
    sa_aurora_4node_host.ipynb  runs the four-node Aurora deployment
cpu_gpu/
  full_experiments.ipynb
  matmul_mali400.py
README.md
```

The generated folders of the Vivado project and the Vitis HLS cache were removed,
since both are reproduced by the tools.

Two build outputs are kept on purpose. Each design ships the exported hardware of
its reference build, under the same name its notebook asks for, so both can be
programmed and run without installing Vivado at all. Sections 1 to 3 below are
only needed to rebuild the hardware from source. To run the designs as delivered,
go straight to Section 4.

---

## Requirements

**Tools**

- Vitis HLS 2024.2
- Vivado 2024.2

The version is a requirement, not a preference. The block design Tcl scripts are
written by Vivado 2024.2 and fail on a different version.

**Target**

- Device `xczu4eg-sfvc784-2-e`
- Board part `ictp.it:hyperfpga_4ge21:part0:1.0`
- Programmable logic clock 300 MHz requested, 299.997 MHz measured

---

## 1. Build the HLS IP

The folder `fpga/hls/` is a Vitis HLS component and can be opened directly in the
Vitis Unified IDE. The part, the clock and the top function are already recorded
in `hls_config.cfg`, so none of them need to be set by hand.

Run C-simulation to check `sa_grid` against the reference in `tb_sa_grid.cpp`,
then run C-synthesis, then export the design as an IP for the Vivado IP catalog.

The packaged result is already provided in `fpga/hls/sa_double_2by2/`, so this
step can be skipped when only rebuilding the hardware.

---

## 2. Rebuild the single-node grid design

**Set the IP repository path before opening the project.** The generated output
products were removed from this repository, so Vivado regenerates them on open,
and regeneration fails if it cannot find the systolic block IP. The path stored
inside the `.xpr` points at the machine the project was built on and will not
exist elsewhere.

Open Vivado, and in the Tcl console:

```tcl
open_project <path>/fpga/vivado/sa_q4/sa_q4.xpr
set_property ip_repo_paths {<path>/fpga/hls/sa_double_2by2} [current_project]
update_ip_catalog
```

Then open the block design, let the output products generate, run synthesis and
implementation, generate the bitstream and export the hardware to an `.xsa`
file.

This design carries an integrated logic analyzer, used to measure the compute
frame of the grid at 75 cycles.

Rebuilding is optional. `sa_q4_ILA2.xsa` in the same folder is the export of the
reference build and can be programmed as it is.

---

## 3. Rebuild the four-node Aurora design

This is a Hog repository. The official flow builds the project from the list
files under `Top/`, and it requires the `Hog/` submodule, which a plain archive
download leaves empty. Clone the repository with its submodules if that flow is
wanted.

The route below rebuilds the block design directly and needs no submodule. The
order matters: set the board repository path before creating the project,
otherwise Vivado does not recognize the board part.

```tcl
set_param board.repoPaths {<path>/fpga/vivado/sa_grid_2x2_aurora/BSP}

create_project sa_q4_top ./sa_q4_top -part xczu4eg-sfvc784-2-e
set_property board_part ictp.it:hyperfpga_4ge21:part0:1.0 [current_project]

add_files -fileset sources_1 \
  [glob <path>/fpga/vivado/sa_grid_2x2_aurora/VHDL/*/*.vhd]
add_files -fileset constrs_1 \
  <path>/fpga/vivado/sa_grid_2x2_aurora/Const/GT_BANK_224.xdc

set_property ip_repo_paths \
  {<path>/fpga/vivado/sa_grid_2x2_aurora/IP} [current_project]
update_ip_catalog

source <path>/fpga/vivado/sa_grid_2x2_aurora/BD/sa_q4_top/sa_q4_top.tcl
```

The Aurora cores are Aurora 8B10B at a line rate of 6.25 Gbps on bank 224, and
they expect a 125 MHz reference clock on the dedicated clock input of that bank.

Generate the bitstream and export the hardware. The same bitstream is programmed
on all four nodes.

Rebuilding is optional. The folder `HW/` already holds
`sa_q4_top_wrapper_v_0_0_2.xsa`, the export of the reference build, together with
its unpacked programming files. That export is also the source of the register
offsets used by the status readout in the Aurora notebook.

---

## 4. Program the boards

Both FPGA notebooks program their nodes by firmware name, so the bitstream must
already exist in the firmware store of the cluster server under that exact name:

| Notebook | Firmware name |
|---|---|
| `sa_grid_host.ipynb` | `sa_q4_ILA2` |
| `sa_aurora_4node_host.ipynb` | `sa_q4_top_wrapper_v_0_0_2` |

Change the `FIRMWARE` constant at the top of the notebook if the uploaded name
differs.

Both artifacts are already provided, so nothing has to be built to run either
design:

| Notebook | Upload this |
|---|---|
| `sa_grid_host.ipynb` | `fpga/vivado/sa_q4/sa_q4_ILA2.xsa` |
| `sa_aurora_4node_host.ipynb` | `fpga/vivado/sa_grid_2x2_aurora/HW/sa_q4_top_wrapper_v_0_0_2.xsa` |

For the Aurora design, the already unpacked files are also available in the
`bitstream/` folder beside its export.

If the cluster server unpacks the `.xsa` automatically, upload it and the
notebooks handle the rest.

If it does not, unpack by hand on a machine that has Vivado installed, using the
tool at `https://gitlab.com/ictp-mlab/xsa2bit`:

1. Clone the repository, set the `device-tree-xlnx` submodule to the branch
   matching Vivado 2024.2, then update the submodules.
2. Install the device tree compiler.
3. Copy the `.xsa` into the tool folder.
4. Run `xsa2bins.py`. Pass the Xilinx install root as `/tools/Xilinx`, not the
   full Vivado path, because the script appends the Vivado folder itself.

Before uploading, confirm that the firmware name inside the compiled `.dtbo`
matches the name of the uploaded binary:

```bash
strings <overlay>.dtbo | grep ".bin"
```

A mismatch makes the kernel reject the overlay with a firmware request error.
Recompile the `.dtsi` with `dtc` if the names differ. When the board is
programmed by hand, reserve the node without firmware by setting
`PROGRAM = False` in the notebook.

---

## 5. Run the single-node grid

Open `fpga/notebooks/sa_grid_host.ipynb` on the hub and run the cells in order.
It reserves one `4ge21` node, programs it, builds the operand stream, splits the
problem into 4x4 tiles, runs every tile through the accelerator inside one
remote call, and checks the result against a NumPy reference. A passing run
prints a maximum error of zero.

Two constants control the run, both in the cell under `## Run`:

- `PROGRAM`, set to `False` once the firmware is already loaded on the node
- `RUNS` and `WARMUP`, the number of repeats and the number discarded before
  taking the median

The last two cells sweep the matrix size from 4 to 128 and report the per tile
cost, the share of time spent computing, and the achieved throughput. The sweep
takes a few minutes at the larger sizes, since the tile count grows with the
cube of the size.

Always run the release cell at the end so the node returns to the pool.

---

## 6. Run the four-node Aurora deployment

Open `fpga/notebooks/sa_aurora_4node_host.ipynb`. It reserves four nodes,
programs the Aurora bitstream on all of them, and resolves each grid position to
an engine by hostname. The mapping is fixed by the transceiver cabling of the
carrier and is set in the `MESH` dictionary:

| Grid position | Node | Role |
|---|---|---|
| (0,0) | `hyperfpga-4ge21-0-2` | head, takes operands from its DMA |
| (0,1) | `hyperfpga-4ge21-0-3` | |
| (1,0) | `hyperfpga-4ge21-1-2` | |
| (1,1) | `hyperfpga-4ge21-1-3` | tail, returns the gathered result |

Edit `MESH` if a different set of nodes is cabled.

The notebook contains a gate cell under `## Aurora status` that reads the status
registers of every transceiver on every node and reports the link state together
with the three on-chip frequency counters. This readout requires no debug cable.
Confirm that `channel_up` and `lane_up` read 1 on all sixteen transceivers
before running the transfer cells. See the Status section for the reading
obtained at the time of writing.

The receive channel is armed on every node, not only on the tail, because the
downward output of each block passes through a stream broadcaster whose second
output feeds the local receive channel.

---

## 7. Run the CPU and GPU experiments

Open `cpu_gpu/full_experiments.ipynb`. It reserves four nodes and runs four
experiments: one node with four CPU cores, four nodes with one core each, one
node with one GPU, and four nodes with one GPU each. Matrix sizes are swept from
4 to 128 and every result is checked against a NumPy reference.

`matmul_mali400.py` must sit in the same working directory as the notebook. The
GPU cells read it from the current directory and copy it to each engine, and
they fail if it is missing.

---

## Status

**Single-node grid: complete.** Verified on hardware with exact matches against
the NumPy reference across the full size sweep. All reported FPGA measurements
come from this design.

**Four-node Aurora deployment: brought up, not measured.** All sixteen
transceivers are powered and out of reset, the on-fabric clocks are present and
read correctly by the frequency counters, and the node mapping, position
register and host procedure are verified. Link training does not complete:
`gt_powergood` reads 1 while `channel_up` and `lane_up` read 0 and the
transceiver user clock reads 0, which places the fault at the 125 MHz reference
clock not reaching the clock input of bank 224. That is a platform provisioning
setting outside user control. Cluster-scale measurement is future work.

**Ethernet path: not implemented.** The comparison between the PS Ethernet path
and the PL path described in the project description was not carried out. The
CPU and GPU experiments use the PS path and the FPGA uses the PL path, so the
work is a comparison of platforms rather than a comparison of interconnects.

---

## Attribution

The systolic array design, comprising the HLS kernel, the grid header protocol
and the single-node block design, was developed by Sultanah Almutairi.

The Aurora inter-node integration in `fpga/vivado/sa_grid_2x2_aurora/` was
developed by Maynor Ballina and Luis García on top of Sultanah design.

The CPU and GPU experiments in `cpu_gpu/` were developed by Fadhlallah
Almohammed.

Work carried out at ICTP STI-MLab under the supervision of Maynor Ballina and
Maria Liz Crespo.
