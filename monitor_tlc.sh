#!/bin/bash
# Monitor TLC verification progress

echo "=== TLC Verification Monitor ==="
echo "Press Ctrl+C to exit"
echo ""

while true; do
    clear
    echo "=== TLC Verification Progress ==="
    echo "Time: $(date '+%H:%M:%S')"
    echo ""
    
    # Check if process is running
    if ps aux | grep -v grep | grep "tlc2.TLC" > /dev/null; then
        echo "Status: ✅ RUNNING"
        ps aux | grep -v grep | grep "tlc2.TLC" | awk '{print "CPU: " $3 "% | Memory: " $4 "% | Runtime: " $10}'
        echo ""
        echo "Latest Progress:"
        tail -5 verification_fix.log | grep "Progress\|Error\|Invariant\|Finished"
    else
        echo "Status: ⏹️  STOPPED"
        echo ""
        echo "Final Results:"
        tail -20 verification_fix.log
        break
    fi
    
    sleep 10
done

