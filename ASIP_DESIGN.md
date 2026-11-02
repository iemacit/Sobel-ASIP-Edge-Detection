
# Sobel ASIP - RISC-V Custom Instruction Design

## 1. Design Objective

The objective is to accelerate the Sobel edge detection
algorithm using custom instructions in a RISC-V processor.

The proposed accelerator calculates the horizontal
and vertical image gradients (Gx and Gy).

## 2. Input Data

- Image pixel width: 8 bits
- Input window: 3x3 pixels
- Total input data: 72 bits
- Input organization: 3 rows, 24 bits per row

## 3. Proposed Custom Instructions

| Instruction | Function |
|---|---|
| SOBEL.SET0 | Load first pixel row |
| SOBEL.SET1 | Load second pixel row |
| SOBEL.SET2 | Load third pixel row |
| SOBEL.GX | Calculate horizontal gradient |
| SOBEL.GY | Calculate vertical gradient |

## 4. Internal Hardware

The accelerator contains:

- Three 24-bit input registers
- Horizontal gradient calculation unit
- Vertical gradient calculation unit
- Signed 12-bit result outputs

## 5. Software and Hardware Partitioning

Hardware:
- Gx calculation
- Gy calculation

Software:
- Image loading
- Pixel window management
- Gradient magnitude calculation
- Square root operation
- Output saturation
- Image saving

## 6. Expected Benefits

- Reduced arithmetic instruction count
- Parallel calculation of Gx and Gy
- Shift-based multiplication by two
- Dedicated Sobel computation hardware

## 7. Limitations

The proposed instruction set has not yet been
implemented in a physical RISC-V processor.

No FPGA timing, power or speedup measurements
are claimed.

The performance benefits will be evaluated
as a future implementation step.
