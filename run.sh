#!/bin/bash
set -e

IMAGE_NAME="astrolabe:latest"

echo "Astrolabe Docker Runner"
echo
echo "How do you want to provide index files?"
echo " 1) Use an existing directory on your system"
echo " 2) Download index files from inside the container (script provided)"
echo
read -p "Enter choice (1 or 2): " CHOICE
echo

# OPTION 1: USER PROVIDES LOCAL INDEX DIRECTORY

if [[ "$CHOICE" == "1" ]]; then
	read -p "Enter the FULL PATH to your index directory: " INDEX_DIR

	if [[ ! -d "$INDEX_DIR" ]]; then
		echo "ERROR: Directory '$INDEX_DIR' does not exist."
		exit 1
	fi

	echo
	echo "Launching container with your index directory mounted:"
	echo " Host: $INDEX_DIR"
	echo " -> /data/index (inside container)"
	echo

	docker run --rm -it \
		-v "$INDEX_DIR":/data/index \
		-v "$(pwd)":/work \
		"$IMAGE_NAME"
	
	exit 0
fi

# OPTION 2: DOWNLOADING INDEXES INSIDE THE CONTAINER
if [[ "$CHOICE" == "2" ]]; then
	echo "Indexes will be stored INSIDE the container at /data/index."
	echo "These won't persist unless you mount a host directory"
	read -p "Do you want to persist the download indexes on the host (y/n): " PERSIST

	if [[ "$PERSIST" == "y" || "$PERSIST" == "Y" ]]; then
		echo
		read -p "Enter directory on host to store downloaded indexes: " PERSIST_DIR

		mkdir -p "$PERSIST_DIR"
		echo "Created/usiing directory: $PERSIST_DIR"
		echo

		docker run --rm -it \
			-v "$PERSIST_DIR":/data/index \
			-v "$(pwd)":/work \
			"$IMAGE_NAME"
		exit 0

	else
		echo
		echo "Running container WITHOUT persistent index storage."
		echo "Indexes you download inside the container will vanish when it exits."
		echo

		docker run --rm -it \
			-v "$(pwd)":/work \
			"$IMAGE_NAME"

		exit 0
	fi
fi

# INVALID INPUT
echo "Invalid choice. Please run again and select 1 or 2."
echo
