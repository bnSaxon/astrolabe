#!/usr/bin/env bash
set -euo pipefail

DEST_DIR=${ASTROMETRY_INDEX_DIR:-/data/index}
BASE_URL="http://data.astrometry.net"

echo "Astrometry.net index download helper"
echo "Destination directory: ${DEST_DIR}"
mkdir -p "${DEST_DIR}"

cat <<EOF
You can choose which index series to download.
Some common choices (rough guide):
  4200: ~ 2-11 arcmin fields
  4100: ~ 11-30 arcmin fields
  5000+: very small fields (high-res, long focal length)

Examples:
  ./download_astrometry_indexes 4200 4201 4202
EOF

if [ "$#" -eq 0 ]; then
    SERIES=(4200)
    FILES=(index-4203.fits index-4204.fits index-4205.fits index-4206.fits)
    echo
    echo "No arguments provided."
    echo "Downloading default indexes for approx 10–60 arcmin fields (4203–4206) into ${DEST_DIR}..."
    for f in "${FILES[@]}"; do
        echo "Downloading ${BASE_URL}/${SERIES}/${f}"
        wget -c -O "${DEST_DIR}/${f}" "${BASE_URL}/${SERIES}/${f}"
    done
else
    echo
    echo "Downloading user-specified series: $* into ${DEST_DIR}"
    for series in "$@"; do
        # Very simple: mirror whole directory for that series (uncompressed .fits only)
        SERIES_DIR="${DEST_DIR}/${series}"
        mkdir -p "${SERIES_DIR}"
        echo "Mirroring ${BASE_URL}/${series} -> ${SERIES_DIR}"
        wget -r -np -nH --cut-dirs=1 -R "index-*.fits.fz" \
            -P "${SERIES_DIR}" \
            "${BASE_URL}/${series}/"
    done
fi

echo "Done. Index files are in ${DEST_DIR}."
