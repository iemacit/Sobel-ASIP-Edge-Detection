# Sobel ASIP Project – Experimental Results

## 1. Python Benchmark Results

The Python reference implementation was tested with three different image sizes. Each experiment was repeated 10 times.

| Image Size | Repetitions | Mean Time (s) | Median Time (s) | Minimum Time (s) | Maximum Time (s) |
| ---------- | ----------: | ------------: | --------------: | ---------------: | ---------------: |
| 256×256    |          10 |      0.211405 |        0.204904 |         0.192781 |         0.252956 |
| 512×512    |          10 |      1.016277 |        1.016766 |         0.942522 |         1.094393 |
| 1024×1024  |          10 |      4.700651 |        4.691529 |         4.300693 |         5.260836 |

Execution time increases as image resolution increases. The results show that processing larger images requires substantially more computation.

These measurements represent the Python software implementation only.

## 2. Profiling Results

The Python application was analyzed using `cProfile` with a 512×512 test image.

Selected results:

| Function             | Cumulative Time |
| -------------------- | --------------: |
| main                 |         3.156 s |
| sobel_edge_detection |         2.558 s |
| create_test_image    |         0.549 s |

The Sobel function accounts for approximately 81.05% of the cumulative execution time within the profiled `main` application scope.

This identifies Sobel processing as the main optimization target.

The profiling run includes profiler overhead and must not be directly compared with the unprofiled benchmark measurements.

## 3. Computational Analysis

The Sobel algorithm processes a 3×3 pixel neighborhood using two convolution masks.

The Gx and Gy calculations each contain six non-zero coefficient terms.

The coefficients are limited to:

- -2
- -1
- 0
- 1
- 2

Multiplication by zero can be eliminated, multiplication by one requires no additional operation, and multiplication by two can be implemented using a left shift.

The two gradient components can be calculated in parallel in a dedicated hardware datapath.

## 4. Data Width Analysis

The input image pixels are unsigned 8-bit values.

The maximum absolute value of either Sobel gradient component is:

8 × 255 = 2040

Therefore, a signed 12-bit representation is sufficient for Gx and Gy.

The maximum squared gradient sum is:

2 × 2040² = 8,323,200

This value fits in an unsigned 23-bit representation.

The final gradient magnitude requires up to 12 unsigned bits before the output is clamped to the 8-bit pixel range.

## 5. Verilog Functional Verification

The combinational Sobel module and the registered ASIP-style unit were tested using directed and randomized test cases.

| Verification Stage        | Passed | Failed |
| ------------------------- | -----: | -----: |
| Basic Sobel tests         |      4 |      0 |
| Random Sobel tests        |   1000 |      0 |
| Python–Verilog comparison |   1000 |      0 |
| Basic ASIP unit tests     |      4 |      0 |
| Random ASIP unit tests    |   1000 |      0 |

All reported tests passed.

The Python–Verilog comparison confirms that the tested Gx and Gy calculations produce matching results between the software reference and Verilog model.

These tests establish functional correctness for the tested cases. They do not establish hardware performance.

## 6. Proposed ASIP Architecture

The proposed architecture uses three 24-bit row registers to store a 3×3 pixel window.

The conceptual custom instruction sequence is:

SOBEL.SET0
SOBEL.SET1
SOBEL.SET2
SOBEL.GX
SOBEL.GY

The first three operations load the pixel rows. The final two operations calculate the horizontal and vertical gradient components.

The Verilog ASIP-style unit models this registered data flow.

The custom instruction encoding and integration into a complete RISC-V processor remain future work.

## 7. Amdahl's Law Analysis

Using the profiled Sobel execution fraction:

f = 2.558 / 3.156 ≈ 0.8105

The theoretical overall speedup is estimated using:

S = 1 / ((1 - f) + f / k)

where `k` represents the acceleration factor of the Sobel portion.

If the Sobel portion were accelerated by a factor of four:

S = 1 / ((1 - 0.8105) + (0.8105 / 4))
S ≈ 2.55

This is a theoretical estimate, not a measured hardware speedup. It does not include custom instruction communication overhead or processor integration costs.

## 8. Conclusion

The experiments identified Sobel edge detection as the dominant computational part of the Python application.

The Verilog implementation successfully reproduced the Gx and Gy calculations for all reported verification tests.

The proposed ASIP architecture provides a starting point for accelerating these calculations through custom instructions and a dedicated datapath.

Future work includes RISC-V instruction encoding, processor integration, hardware synthesis, and measurement of execution time, area, and power consumption.

No hardware speedup, area reduction, or power reduction is claimed at this stage.
