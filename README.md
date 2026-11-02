# Sobel ASIP Project

**BIL523 – Application-Specific Instruction Set Processor Design Assignment**

This project investigates the acceleration of the Sobel edge detection algorithm using a proposed custom RISC-V instruction interface.

The project includes:

- A Python software reference implementation.
- Performance benchmarking and profiling.
- A Verilog Sobel hardware model.
- Python–Verilog functional comparison.
- A proposed ASIP instruction design.

## 1. Requirements

### Software

- Python 3.10 or newer
- Pillow

### Hardware simulation

- Icarus Verilog 12.0 or compatible version
- `iverilog`
- `vvp`

## 2. Python setup

Open PowerShell in the project folder:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

If PowerShell blocks activation, use Command Prompt:

```bat
.venv\Scripts\activate.bat
```

## 3. Run the Python reference

Run the default experiment:

```powershell
python main.py
```

Run experiments with different image sizes:

```powershell
python main.py --width 256 --height 256 --repetitions 10 --output-dir output_256

python main.py --width 512 --height 512 --repetitions 10 --output-dir output_512

python main.py --width 1024 --height 1024 --repetitions 10 --output-dir output_1024
```

The program generates a synthetic grayscale image, applies Sobel edge detection, and records benchmark results.

## 4. Measured benchmark results

The following results were obtained from the Python reference implementation using 10 repetitions per image size.

| Image size | Repetitions | Mean time (s) | Median time (s) |
| ---------- | ----------: | ------------: | --------------: |
| 256×256    |          10 |      0.211405 |        0.204904 |
| 512×512    |          10 |      1.016277 |        1.016766 |
| 1024×1024  |          10 |      4.700651 |        4.691529 |

These are measured software execution times on the test computer. They do not represent hardware acceleration results.

## 5. Profiling

Run the Python profiler:

```powershell
python -m cProfile -s cumulative main.py --width 512 --height 512 --profile
```

Save the profiler output:

```powershell
python -m cProfile -s cumulative main.py --width 512 --height 512 --profile > output_512\profile.txt
```

The profiling results identified `sobel_edge_detection` as the main computational hotspot.

Selected profiling results:

| Function             | Cumulative time |
| -------------------- | --------------: |
| main                 |         3.156 s |
| sobel_edge_detection |         2.558 s |
| create_test_image    |         0.549 s |

The profiler measures Python function-level execution costs. It is not a RISC-V hardware instruction counter.

## 6. Sobel algorithm

The implementation uses the classic 3×3 Sobel masks.

**Gx**

```text
-1   0   1
-2   0   2
-1   0   1
```

**Gy**

```text
-1  -2  -1
 0   0   0
 1   2   1
```

Gradient magnitude:

```text
G = sqrt(Gx*Gx + Gy*Gy)
```

Output values are clamped to the range 0–255. Border pixels are set to zero.

## 7. Verilog hardware model

The hardware model is located in the `hardware/` directory.

Main modules:

- `sobel3x3.v`: Combinational Sobel Gx and Gy calculation.
- `sobel_asip_unit.v`: Registered ASIP-style unit with three 24-bit row registers.
- `tb_sobel3x3.v`: Basic Sobel testbench.
- `tb_sobel_asip_unit.v`: Basic registered unit testbench.
- `tb_sobel_asip_random.v`: Randomized ASIP unit testbench.
- `tb_sobel_compare.v`: Testbench used for Python–Verilog comparison.

The hardware unit calculates Gx and Gy. Gradient magnitude, square root, and output clamping remain outside the hardware unit in this initial design.

## 8. Functional verification

The following tests were completed:

| Test                      | Successful tests | Failed tests |
| ------------------------- | ---------------: | -----------: |
| Basic Sobel tests         |                4 |            0 |
| Random Sobel tests        |             1000 |            0 |
| Python–Verilog comparison |             1000 |            0 |
| Basic ASIP unit tests     |                4 |            0 |
| Random ASIP unit tests    |             1000 |            0 |

All reported test cases passed.

These results demonstrate functional agreement for the tested inputs. They do not demonstrate FPGA implementation, clock frequency, power consumption, silicon area, or execution speedup.

## 9. ASIP design proposal

The proposed custom instruction interface uses three row-loading operations and two computation operations:

```text
SOBEL.SET0
SOBEL.SET1
SOBEL.SET2
SOBEL.GX
SOBEL.GY
```

Each row contains three 8-bit pixels and is transferred as a 24-bit value.

The three row registers preserve the input window. The Gx and Gy operations return signed 12-bit results.

This is a conceptual RISC-V custom instruction proposal. The instruction encoding, processor integration, and execution on a real RISC-V implementation have not yet been completed.

## 10. Hardware optimization opportunity

The Sobel coefficients are limited to -2, -1, 0, 1, and 2.

Therefore:

- Multiplication by zero can be eliminated.
- Multiplication by one requires no additional arithmetic operation.
- Multiplication by two can be implemented using a left shift.
- Negative coefficients can be implemented using subtraction or sign changes.

The proposed hardware datapath calculates Gx and Gy in parallel.

## 11. Project limitations

The current project provides:

- Measured Python benchmark results.
- Python function-level profiling.
- Verilog functional simulation.
- Randomized functional verification.
- A proposed custom instruction interface.

The project does not yet provide:

- A complete RISC-V processor implementation.
- FPGA synthesis results.
- Measured hardware execution time.
- Measured power or area results.

No hardware speedup or power reduction is claimed.

## 12. AI usage declaration

An AI-based assistant was used for guidance during algorithm analysis, code development, debugging, and report preparation. The software benchmarks and Verilog simulations were executed by the student, and the reported results are based on those experiments.

## 13. Repository

Repository URL: **To be added after publishing the project to GitHub.**
