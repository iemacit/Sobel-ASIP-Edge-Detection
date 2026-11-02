
from __future__ import annotations

import argparse
import csv
import json
import math
import statistics
import time
from pathlib import Path

from PIL import Image


def create_test_image(path: Path, width: int, height: int) -> None:
    """Create a deterministic grayscale test image."""
    image = Image.new("L", (width, height))
    pixels = image.load()

    for y in range(height):
        for x in range(width):
            if 80 <= x < 220 and 70 <= y < 250:
                value = 220
            elif 280 <= x < 430 and 180 <= y < 400:
                value = 40
            else:
                value = 120

            value = max(0, min(255, value + (x // 32) - (y // 48)))
            pixels[x, y] = value

    image.save(path)


def load_grayscale(path: Path) -> list[list[int]]:
    image = Image.open(path).convert("L")
    width, height = image.size
    raw = list(image.getdata())
    return [raw[y * width:(y + 1) * width] for y in range(height)]


def sobel_edge_detection(gray: list[list[int]]) -> list[list[int]]:
    height = len(gray)
    width = len(gray[0]) if height else 0
    output = [[0 for _ in range(width)] for _ in range(height)]

    gx_kernel = (
        (-1, 0, 1),
        (-2, 0, 2),
        (-1, 0, 1),
    )
    gy_kernel = (
        (-1, -2, -1),
        (0, 0, 0),
        (1, 2, 1),
    )

    for y in range(1, height - 1):
        for x in range(1, width - 1):
            gx = 0
            gy = 0

            for ky in range(3):
                for kx in range(3):
                    pixel = gray[y + ky - 1][x + kx - 1]
                    gx += pixel * gx_kernel[ky][kx]
                    gy += pixel * gy_kernel[ky][kx]

            magnitude = int(math.sqrt(gx * gx + gy * gy))
            output[y][x] = min(255, magnitude)

    return output


def save_grayscale_matrix(matrix: list[list[int]], path: Path) -> None:
    height = len(matrix)
    width = len(matrix[0]) if height else 0
    image = Image.new("L", (width, height))
    image.putdata([value for row in matrix for value in row])
    image.save(path)


def benchmark(gray: list[list[int]], repetitions: int) -> dict:
    durations = []

    # Warm-up run (excluded from measurements).
    sobel_edge_detection(gray)

    for _ in range(repetitions):
        start = time.perf_counter()
        sobel_edge_detection(gray)
        durations.append(time.perf_counter() - start)

    return {
        "repetitions": repetitions,
        "mean_seconds": statistics.mean(durations),
        "median_seconds": statistics.median(durations),
        "min_seconds": min(durations),
        "max_seconds": max(durations),
        "all_seconds": durations,
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Python reference implementation for Sobel edge detection."
    )

    parser.add_argument("--input", type=Path, help="Input image path.")
    parser.add_argument("--output-dir", type=Path, default=Path("output"))
    parser.add_argument("--repetitions", type=int, default=10)
    parser.add_argument("--width", type=int, default=512)
    parser.add_argument("--height", type=int, default=512)
    parser.add_argument("--profile", action="store_true")

    args = parser.parse_args()

    if args.repetitions < 1:
        parser.error("--repetitions must be at least 1")

    if args.width < 3 or args.height < 3:
        parser.error("Image width and height must be at least 3")

    args.output_dir.mkdir(parents=True, exist_ok=True)

    input_path = args.input

    if input_path is None:
        input_path = args.output_dir / "test_image.png"
        create_test_image(input_path, args.width, args.height)

    if not input_path.exists():
        parser.error(f"Input image not found: {input_path}")

    gray = load_grayscale(input_path)
    actual_height = len(gray)
    actual_width = len(gray[0])

    print(f"Actual image size: {actual_width} x {actual_height}")

    edge_path = args.output_dir / "sobel_edges.png"

    if args.profile:
        start = time.perf_counter()
        edges = sobel_edge_detection(gray)
        elapsed = time.perf_counter() - start

        save_grayscale_matrix(edges, edge_path)

        print(f"Sobel processing time: {elapsed:.6f} seconds")
        print(f"Edge image: {edge_path.resolve()}")
        return

    result = benchmark(gray, args.repetitions)

    # Save the output image separately from benchmark repetitions.
    edges = sobel_edge_detection(gray)
    save_grayscale_matrix(edges, edge_path)

    result["input_image"] = str(input_path)
    result["image_width"] = actual_width
    result["image_height"] = actual_height
    result["algorithm"] = "Classic Sobel; Euclidean gradient magnitude"

    json_path = args.output_dir / "benchmark.json"
    json_path.write_text(
        json.dumps(result, indent=2),
        encoding="utf-8"
    )

    csv_path = args.output_dir / "benchmark.csv"

    with csv_path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["run", "duration_seconds"])

        for index, duration in enumerate(result["all_seconds"], start=1):
            writer.writerow([index, f"{duration:.9f}"])

    print("Sobel processing completed.")
    print(f"Image size: {actual_width} x {actual_height}")
    print(f"Repetitions: {args.repetitions}")
    print(f"Average: {result['mean_seconds']:.6f} seconds")
    print(f"Median: {result['median_seconds']:.6f} seconds")
    print(f"Minimum: {result['min_seconds']:.6f} seconds")
    print(f"Maximum: {result['max_seconds']:.6f} seconds")
    print(f"Edge image: {edge_path.resolve()}")
    print(f"Benchmark JSON: {json_path.resolve()}")
    print(f"Benchmark CSV: {csv_path.resolve()}")


if __name__ == "__main__":
    main()
