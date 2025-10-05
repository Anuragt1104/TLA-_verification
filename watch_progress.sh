#!/bin/bash
# Simple progress monitor for TLC verification

echo "=== TLC Verification Monitor ==="
echo "Press Ctrl+C to exit"
echo ""

while true; do
    clear
    echo "=== TLC Verification Progress ==="
    echo "Time: $(date '+%H:%M:%S')"
    echo ""
    
    # Check if process is running
    if ps aux | grep -v grep | grep "tlc2.TLC" | grep "verification_fix2.log" > /dev/null; then
        echo "✅ Status: RUNNING"
        ps aux | grep -v grep | grep "tlc2.TLC" | grep "verification_fix2.log" | awk '{print "   CPU: " $3 "% | Memory: " $4 "% | Runtime: " $10}'
        echo ""
        echo "Latest Progress:"
        tail -5 verification_fix2.log | grep "Progress\|Error\|Invariant\|Finished"
        echo ""
        echo "Last 3 lines:"
        tail -3 verification_fix2.log
    else
        echo "⏹️  Status: STOPPED"
        echo ""
        echo "=== Final Results ==="
        tail -30 verification_fix2.log
        break
    fi
    
    sleep 10
done

