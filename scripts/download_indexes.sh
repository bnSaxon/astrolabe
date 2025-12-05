#!/usr/bin/env bash
set -euo pipefail

DEST_DIR=${ASTROMETRY_INDEX_DIR:-/astrolabe/data/index}
BASE_URL="http://data.astrometry.net"

echo "Astrometry.net index download helper"
echo "Destination directory: ${DEST_DIR}"
mkdir -p "${DEST_DIR}"

cat <<EOF
You can choose which index series to download.
Some common choices (rough guide):
  4200: ~  2–11 arcmin fields
  4100: ~ 11–30 arcmin fields
  5000+: very small fields (high-res, long focal length)

Examples:
  ./download_astrometry_indexes 4200 4201 4202
  ./download_astrometry_indexes 5200        (special LITE set)
EOF

if [ "$#" -eq 0 ]; then
    # Default: download a small set from series 4200
    SERIES=4200
    FILES=(
        index-4203.fits
        index-4204.fits
        index-4205.fits
        index-4206.fits
    )

    echo
    echo "No arguments provided."
    echo "Downloading default indexes (${SERIES}: 4203–4206) into ${DEST_DIR}..."
    for f in "${FILES[@]}"; do
        echo "Downloading ${BASE_URL}/${SERIES}/${f}"
        wget -c -O "${DEST_DIR}/${f}" "${BASE_URL}/${SERIES}/${f}"
    done
else
    echo
    echo "Downloading user-specified series: $* into ${DEST_DIR}"
    for series in "$@"; do

        # Special case: 5200 "LITE" set from NERSC portal
        if [[ "$series" == "5200" ]]; then
    		echo
		echo "Special handling for 5200 LITE indexes (5200/5201/5202)..."

    		for prefix in 5200 5201 5202; do
        		for ((i=0; i<48; i++)); do
            			I=$(printf "%02d" "$i")
            			url="https://portal.nersc.gov/project/cosmo/temp/dstn/index-5200/LITE/index-${prefix}-${I}.fits"
            			tmp="${DEST_DIR}/.partial-index-${prefix}-${I}.fits"
            			final="${DEST_DIR}/index-${prefix}-${I}.fits"

            			echo "Downloading ${url}"
            			wget -c -O "${tmp}" "${url}"

            			echo "Moving to ${final}"
            			mv -f "${tmp}" "${final}"
        		done
    		done
    		continue
	fi


        # Default handling for "normal" series via data.astrometry.net
        SERIES_DIR="${DEST_DIR}/${series}"
        mkdir -p "${SERIES_DIR}"

        echo
        echo "Mirroring ${BASE_URL}/${series}/ -> ${SERIES_DIR}"
        wget -r -np -nH --cut-dirs=1 -R "index-*.fits.fz" \
            -P "${SERIES_DIR}" \
            "${BASE_URL}/${series}/"

        echo "Moving index-*.fits from ${SERIES_DIR} to ${DEST_DIR}"
        find "${SERIES_DIR}" -type f -name "index-*.fits" -exec mv -f {} "${DEST_DIR}/" \;

        # Clean up now-empty series directory
        find "${SERIES_DIR}" -type d -empty -delete || true
    done
fi

echo
echo "Done. Index files are in ${DEST_DIR}."

