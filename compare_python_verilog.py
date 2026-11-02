
import random
import subprocess
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parent
HARDWARE = ROOT / "hardware"

random.seed(42)

TEST_COUNT = 1000

# 1000 ortak test matrisi oluştur
vectors = [
    [random.randint(0, 255) for _ in range(9)]
    for _ in range(TEST_COUNT)
]

# Verilog'un okuyacağı dosyayı oluştur
vector_file = HARDWARE / "vectors.txt"

with open(vector_file, "w") as f:
    for v in vectors:
        f.write(" ".join(f"{x:02X}" for x in v) + "\n")

# Verilog devresini derle
compile_result = subprocess.run(
    [
        r"C:\iverilog\bin\iverilog.exe",
        "-g2012",
        "-o",
        str(HARDWARE / "compare.vvp"),
        str(HARDWARE / "sobel3x3.v"),
        str(HARDWARE / "tb_sobel_compare.v"),
    ],
    capture_output=True,
    text=True,
)

if compile_result.returncode != 0:
    print("Derleme hatasi:")
    print(compile_result.stderr)
    raise SystemExit(1)

# Simülasyonu çalıştır
simulation = subprocess.run(
    [
        r"C:\iverilog\bin\vvp.exe",
        str(HARDWARE / "compare.vvp"),
    ],
    cwd=ROOT,
    capture_output=True,
    text=True,
)

if simulation.returncode != 0:
    print("Simulasyon hatasi:")
    print(simulation.stdout)
    print(simulation.stderr)
    raise SystemExit(1)

# Verilog sonuçlarını al
verilog_results = []

for line in simulation.stdout.splitlines():
    if line.startswith("RESULT,"):
        _, gx, gy = line.split(",")
        verilog_results.append((int(gx), int(gy)))

if len(verilog_results) != TEST_COUNT:
    print("Beklenen test sayisi:", TEST_COUNT)
    print("Verilog sonuc sayisi:", len(verilog_results))
    print(simulation.stdout)
    raise SystemExit("Test sayisi uyusmuyor!")

# Python ve Verilog sonuçlarını karşılaştır
rows = []
errors = 0

for index, (v, hw) in enumerate(zip(vectors, verilog_results)):
    p00, p01, p02, p10, p11, p12, p20, p21, p22 = v

    python_gx = (
        -p00 + p02
        - 2 * p10 + 2 * p12
        - p20 + p22
    )

    python_gy = (
        -p00 - 2 * p01 - p02
        + p20 + 2 * p21 + p22
    )

    verilog_gx, verilog_gy = hw

    match = (
        python_gx == verilog_gx
        and python_gy == verilog_gy
    )

    if not match:
        errors += 1

    rows.append([
        index + 1,
        python_gx,
        verilog_gx,
        python_gy,
        verilog_gy,
        "PASS" if match else "FAIL"
    ])

# CSV raporu oluştur
csv_path = ROOT / "python_verilog_comparison.csv"

with open(csv_path, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow([
        "Test",
        "Python_Gx",
        "Verilog_Gx",
        "Python_Gy",
        "Verilog_Gy",
        "Result"
    ])
    writer.writerows(rows)

print("\nPYTHON - VERILOG COMPARISON")
print("---------------------------")
print("Total tests:", TEST_COUNT)
print("Successful:", TEST_COUNT - errors)
print("Failed:", errors)
print("CSV file:", csv_path)

if errors == 0:
    print("\nALL PYTHON-VERILOG TESTS PASSED!")
else:
    print("\nCOMPARISON FAILED!")
    raise SystemExit(1)
