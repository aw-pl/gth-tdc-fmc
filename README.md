# Alice3-tdc-mgt

A Git-friendly FPGA project for the Alice3 platform featuring a MicroBlaze soft-core processor, Time-to-Digital Converter (TDC) logic, and GTH multi-gigabit transceivers. This project uses a scripted flow to keep the repository clean and avoid tracking bloated Xilinx-generated files.

## ⚠️ Hardware Requirements

This project is designed for the following hardware setup:
* **Carrier Board**: AFCKU v1 2023.
* **High-Speed Links**: Utilizes GTH transceivers for fast data transmission.

## Project Structure

The repository is organized to separate hardware design, software source code, and build artifacts:

```text
.
├── bd/                     # Block Design files (.bd with Core Container enabled)
├── hdl/                    # VHDL/Verilog source files (TDC, GTH wrappers, FIFOs)
├── ip/                     # Custom IP Cores (e.g., gtwizard_ultrascale_0.xci)
├── sim/                    # Simulation testbenches
├── xdc/                    # FPGA constraint files (pinout, timing)
├── software/
│   ├── src/                # Pure C source code and Linker Script (Tracked by Git)
│   ├── build_sw.tcl        # XSCT script to recreate Vitis workspace
│   └── design_1_wrapper.xsa# Hardware hand-off file from Vivado
├── make.tcl                # Vivado script to recreate the hardware project
└── README.md
```

---

## 🚀 Getting Started

### 1. Hardware Generation (Vivado)
To recreate the Vivado project from scratch:

1. Open your terminal in the project root.
2. Run Vivado in Tcl mode:
   ```bash
   vivado -mode batch -source make.tcl
   ```
3. This will create a `build/` directory containing the full Vivado project (`tdc_gth_new.xpr`).
4. Open the project in GUI if needed: `vivado build/tdc_gth_new.xpr`.
5. **Generate Bitstream** and export the hardware (**File > Export > Export Hardware**) to `software/design_1_wrapper.xsa`.

### 2. Software Setup (Vitis)
The Vitis workspace is **not** tracked by Git. To recreate it:

1. Navigate to the software directory:
   ```bash
   cd software
   ```
2. Run the XSCT build script:
   ```bash
   xsct build_sw.tcl
   ```
3. This script will:
   * Create a new workspace.
   * Configure the Hardware Platform and BSP (including the `xiltimer` library).
   * **Fix UART settings** (explicitly sets `stdout/stdin` to `axi_uart16550_1`).
   * Import sources from `src/` (hard copy for IDE stability).
   * Compile the `.elf` file.

### 3. Running the IDE
To open the project in the Vitis GUI:
```bash
vitis -workspace ./workspace &
```
*Pro-tip: If the Project Explorer appears empty, close the "Welcome" tab to reveal your projects.*

---

## 💡 Pro-Tips & Workflow

### The "Source of Truth" Rule
Always remember that **`software/src/`** is your source of truth. 
* Vitis IDE edits files inside `workspace/tdc_app/src/`. 
* These changes are **NOT** automatically tracked by Git because the workspace is ignored.
* **Important:** After making changes in the IDE, sync them back to the main folder:
  ```bash
  cp workspace/tdc_app/src/*.c ./src/
  cp workspace/tdc_app/src/*.h ./src/
  cp workspace/tdc_app/src/lscript.ld ./src/
  ```

### Clean Builds
If Vivado or Vitis starts acting weird, just wipe the build folders and start fresh. It takes seconds:
```bash
# For Vivado
rm -rf build
vivado -mode batch -source make.tcl

# For Vitis
cd software
rm -rf workspace
xsct build_sw.tcl
```

### UART Debugging
This project uses **`axi_uart16550_1`** as the primary console. If you see no output in your serial terminal (PuTTY/minicom), ensure your BSP settings in the script or GUI are pointing to the correct UART instance.

### Git Hygiene
Avoid force-adding files from the `build/` or `workspace/` directories. Rely on your scripts to generate them locally!
