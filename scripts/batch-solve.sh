#!/bin/bash
set -e

INPUT_DIR=/astrolabe/data/input_images
OUTPUT_DIR=/astrolabe/data/output_solves

# Ensure the output dir exists
mkdir -p "$OUTPUT_DIR"

# Loop through each image in the input directory
for img in "$INPUT_DIR"/*; do
	[ -f "$img" ] || continue
	name=$(basename "$img")    # eg., bigdipper.jpg
	base="${name%/*}"          # eg., bigdipper
	outdir="$OUTPUT_DIR/$base" # eg., /astrolabe/data/output/bigdipper

	mkdir -p "$outdir"

	echo "Solving $img into $outdir..."

	solve-field \
		--dir "$outdir" \
		--overwrite \
		"$img"
done

echo "Finished. Outputs in $OUTPUT_DIR"
