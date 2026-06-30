#!/bin/bash
# Description: Spikes CPU usage to test scaling rules.

# 1. Install stress utility if not present
if ! command -v stress-ng &> /dev/null; then
    echo "Installing stress-ng tool..."
    sudo apt update -y && sudo apt install -y stress-ng
fi

# 2. Get the number of CPU cores available
CORES=$(nproc)

# 3. Define target parameters
CPU_LOAD_PERCENT=85
DURATION_SECONDS=600 # 10 Minutes

echo "========================================================="
echo "Starting CPU Stress Test..."
echo "Targeting ${CORES} cores at ${CPU_LOAD_PERCENT}% load for ${DURATION_SECONDS}s."
echo "Press Ctrl+C to abort early."
echo "========================================================="

# 4. Run stress-ng in the background
sudo stress-ng --cpu $CORES --cpu-load $CPU_LOAD_PERCENT --timeout ${DURATION_SECONDS}s &

echo "CPU stress process launched in background."
echo "Monitor real-time status using the 'top' or 'htop' command."