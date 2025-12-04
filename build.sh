#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="astrometry-net:latest"

echo "Building Docker image: ${IMAGE_NAME}"
docker build -t "${IMAGE_NAME}" .

echo
echo "To run with your NVMe index directory mounted, use:"
echo
echo "  docker run --rm -it \\"
echo "    -v /mnt/nvme/astrometry-index:/data/index \\"
echo "    -v \$(pwd):/work \\"
echo "    ${IMAGE_NAME}"
echo
echo "Inside the container, you can:"
echo "  - run 'download_astrometry_indexes' to fetch some index files, or"
echo "  - run 'solve-field your_image.fits' directly if indexes already exist."
