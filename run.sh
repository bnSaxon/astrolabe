#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-astrolabe:latest}"

INPUT_HOST_DIR="$(pwd)/data/input_images"

echo "Astrolabe Docker Runner"
echo
echo "How do you want to provide index files?"
echo " 1) Use an existing directory on your system"
echo " 2) Download index files from inside the container (script provided)"
echo
read -r -p "Enter choice (1 or 2): " CHOICE
echo

# Common docker args: interactive container, mount input + project root
BASE_DOCKER_ARGS=(
  --rm
  -it
  -v "${INPUT_HOST_DIR}:/astrolabe/data/input_images"
  -v "$(pwd):/work"
)

# Helper to actually run docker with assembled args
run_container() {
  local args=("${BASE_DOCKER_ARGS[@]}" "$@")
  echo
  echo "Running: docker run ${args[*]} ${IMAGE_NAME}"
  echo
  docker run "${args[@]}" "${IMAGE_NAME}"
}


# OPTION 1: USER PROVIDES LOCAL INDEX DIR
if [[ "$CHOICE" == "1" ]]; then
  read -r -p "Enter the FULL PATH to your index directory: " INDEX_DIR

  if [[ ! -d "$INDEX_DIR" ]]; then
    echo "ERROR: Directory '$INDEX_DIR' does not exist."
    exit 1
  fi

  echo
  echo "Mounting index directory:"
  echo " Host: $INDEX_DIR"
  echo "  -> /astrolabe/data/index (inside container)"
  echo

  read -r -p "Do you want solved outputs to persist to host? (y/n): " OUTPUT_PERSIST

  if [[ "$OUTPUT_PERSIST" == "y" || "$OUTPUT_PERSIST" == "Y" ]]; then
    read -r -p "Enter host directory to store output solves: " OUTPUT_PERSIST_DIR
    mkdir -p "$OUTPUT_PERSIST_DIR"

    echo
    echo "Launching container with:"
    echo " Index Dir:  $INDEX_DIR -> /astrolabe/data/index"
    echo " Output Dir: $OUTPUT_PERSIST_DIR -> /astrolabe/data/output_solves"
    run_container \
      -v "$INDEX_DIR:/astrolabe/data/index" \
      -v "$OUTPUT_PERSIST_DIR:/astrolabe/data/output_solves"
  else
    echo
    echo "Launching container with ONLY the index directory mounted."
    echo "Outputs will be ephemeral (inside-container only)."
    echo " Index Dir: $INDEX_DIR -> /astrolabe/data/index"
    run_container \
      -v "$INDEX_DIR:/astrolabe/data/index"
  fi

  exit 0
fi


# OPTION 2: DOWNLOAD INDEXES IN CONTAINER
if [[ "$CHOICE" == "2" ]]; then
  echo "Indexes will be stored inside the container at /astrolabe/data/index."
  echo "These won't persist unless you mount a host directory."
  echo
  read -r -p "Do you want the downloaded indexes to persist on the host? (y/n): " INDEX_PERSIST

  if [[ "$INDEX_PERSIST" == "y" || "$INDEX_PERSIST" == "Y" ]]; then
    echo
    read -r -p "Enter directory on host to store downloaded indexes: " INDEX_PERSIST_DIR
    mkdir -p "$INDEX_PERSIST_DIR"
    echo "Created/using directory: $INDEX_PERSIST_DIR"
    echo

    read -r -p "Do you want solved outputs to persist on the host? (y/n): " OUTPUT_PERSIST

    if [[ "$OUTPUT_PERSIST" == "y" || "$OUTPUT_PERSIST" == "Y" ]]; then
      read -r -p "Enter host directory to store output solves: " OUTPUT_PERSIST_DIR
      mkdir -p "$OUTPUT_PERSIST_DIR"

      echo
      echo "Launching container. Downloaded indexes and solved outputs will persist."
      echo " Indexes -> $INDEX_PERSIST_DIR"
      echo " Outputs -> $OUTPUT_PERSIST_DIR"
      run_container \
        -v "$INDEX_PERSIST_DIR:/astrolabe/data/index" \
        -v "$OUTPUT_PERSIST_DIR:/astrolabe/data/output_solves"
    else
      echo
      echo "Launching container. Downloaded indexes will persist. Outputs will NOT persist."
      echo " Indexes -> $INDEX_PERSIST_DIR"
      run_container \
        -v "$INDEX_PERSIST_DIR:/astrolabe/data/index"
    fi

    exit 0
  else
    echo
    echo "Running container WITHOUT persistent index storage."
    echo "Indexes you download inside the container will vanish when it exits."
    echo
    read -r -p "Do you want solved outputs to persist on the host? (y/n): " OUTPUT_PERSIST

    if [[ "$OUTPUT_PERSIST" == "y" || "$OUTPUT_PERSIST" == "Y" ]]; then
      read -r -p "Enter host directory to store output solves: " OUTPUT_PERSIST_DIR
      mkdir -p "$OUTPUT_PERSIST_DIR"

      echo
      echo "Launching container. Downloaded indexes will NOT persist. Output solves WILL."
      echo " Outputs -> $OUTPUT_PERSIST_DIR"
      run_container \
        -v "$OUTPUT_PERSIST_DIR:/astrolabe/data/output_solves"
    else
      echo
      echo "Launching container. Downloaded indexes and output solves will NOT persist to host."
      run_container
    fi

    exit 0
  fi
fi


# INVALID INPUT
echo "Invalid choice. Please run again and select 1 or 2."
echo
exit 1

