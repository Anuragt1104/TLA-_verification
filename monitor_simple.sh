#!/bin/bash
echo "Monitoring TLC Verification - Press Ctrl+C to stop"
echo "=================================================="
echo ""

while true; do
    echo "Time: $(date '+%H:%M:%S')"
    echo "---"
    tail -1 verification_fix2.log
    echo ""
    sleep 15
done
