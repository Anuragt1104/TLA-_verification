#!/bin/bash
# Comprehensive Test Runner for Alpenglow Verification
# This script runs all verification tests required for the challenge

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Find TLA+ tools
TLATOOLS=$(find ~/.cursor/extensions -name "tla2tools.jar" 2>/dev/null | head -1)

if [ -z "$TLATOOLS" ]; then
    echo -e "${RED}Error: tla2tools.jar not found!${NC}"
    echo "Please ensure TLA+ Toolbox extension is installed in Cursor."
    exit 1
fi

echo "Using TLA+ tools: $TLATOOLS"
echo ""

# Check disk space
AVAILABLE=$(df -h /System/Volumes/Data | tail -1 | awk '{print $4}')
echo "Available disk space: $AVAILABLE"
if [ $(df /System/Volumes/Data | tail -1 | awk '{print $5}' | tr -d '%') -gt 90 ]; then
    echo -e "${YELLOW}Warning: Disk is >90% full. Consider freeing space.${NC}"
    echo "Recommended: Delete old TLC temp files"
    echo "  rm -rf /var/folders/*/T/tlc-*"
    echo ""
fi

# Function to run a test
run_test() {
    local config=$1
    local name=$2
    local workers=$3
    local memory=$4
    local logfile=$5
    
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}Starting Test: $name${NC}"
    echo -e "${GREEN}Config: $config${NC}"
    echo -e "${GREEN}Log: $logfile${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo ""
    
    java -XX:+UseParallelGC -Xmx${memory} \
        -cp "$TLATOOLS" \
        tlc2.TLC -cleanup -config "$config" \
        -workers $workers -deadlock Alpenglow.tla \
        > "$logfile" 2>&1 &
    
    local pid=$!
    echo "Process ID: $pid"
    echo "Monitor with: tail -f $logfile"
    echo ""
    
    # Wait a bit and check if process started successfully
    sleep 5
    if ps -p $pid > /dev/null; then
        echo -e "${GREEN}Test started successfully!${NC}"
        echo "PID: $pid"
        echo ""
        return 0
    else
        echo -e "${RED}Test failed to start!${NC}"
        echo "Check $logfile for errors"
        return 1
    fi
}

# Function to check test status
check_status() {
    local logfile=$1
    local name=$2
    
    echo "Checking status of $name..."
    
    if grep -q "No errors found" "$logfile" 2>/dev/null; then
        echo -e "${GREEN}✅ $name: PASSED${NC}"
        return 0
    elif grep -q "Invariant.*is violated" "$logfile" 2>/dev/null; then
        echo -e "${RED}❌ $name: FAILED (Invariant violation)${NC}"
        return 1
    elif grep -q "Finished in" "$logfile" 2>/dev/null; then
        if grep -q "Error" "$logfile" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  $name: COMPLETED WITH ERRORS${NC}"
            return 2
        else
            echo -e "${GREEN}✅ $name: COMPLETED${NC}"
            return 0
        fi
    else
        echo -e "${YELLOW}🔄 $name: RUNNING${NC}"
        return 3
    fi
}

# Main menu
echo "========================================="
echo "Alpenglow Comprehensive Verification"
echo "========================================="
echo ""
echo "Select tests to run:"
echo "1) 4-Node Safety (Quick, ~2 hours)"
echo "2) 10-Node Safety (Comprehensive, ~12-20 hours)"
echo "3) Resilience Test (20% Byzantine, ~12-24 hours)"
echo "4) All Tests (Run all sequentially)"
echo "5) Check Status (Check running tests)"
echo "6) Monitor Tests (Live tail of logs)"
echo ""
read -p "Enter choice [1-6]: " choice

case $choice in
    1)
        echo "Running 4-Node Safety Test..."
        run_test "Alpenglow.cfg" "4-Node Safety" 2 "4g" "verification_4node_final.log"
        ;;
    2)
        echo "Running 10-Node Safety Test..."
        echo "NOTE: This will take 12-20 hours!"
        read -p "Continue? [y/N]: " confirm
        if [[ $confirm == [yY] ]]; then
            run_test "Alpenglow_10nodes.cfg" "10-Node Safety" 4 "8g" "verification_10nodes.log"
        fi
        ;;
    3)
        echo "Running Resilience Test (20% Byzantine)..."
        echo "NOTE: This will take 12-24 hours!"
        read -p "Continue? [y/N]: " confirm
        if [[ $confirm == [yY] ]]; then
            run_test "Alpenglow_resilience.cfg" "Resilience Test" 4 "8g" "verification_resilience.log"
        fi
        ;;
    4)
        echo "Running ALL tests sequentially..."
        echo "This will take 24-48+ hours total!"
        read -p "Are you sure? [y/N]: " confirm
        if [[ $confirm == [yY] ]]; then
            run_test "Alpenglow.cfg" "4-Node Safety" 2 "4g" "verification_4node_final.log"
            echo "Waiting 2 hours before starting next test..."
            sleep 7200
            run_test "Alpenglow_10nodes.cfg" "10-Node Safety" 4 "8g" "verification_10nodes.log"
            echo "Waiting 12 hours before starting next test..."
            sleep 43200
            run_test "Alpenglow_resilience.cfg" "Resilience Test" 4 "8g" "verification_resilience.log"
        fi
        ;;
    5)
        echo "Checking test status..."
        echo ""
        check_status "verification_4node_final.log" "4-Node Safety"
        check_status "verification_10nodes.log" "10-Node Safety"
        check_status "verification_resilience.log" "Resilience Test"
        check_status "verification_fix2.log" "Previous Run"
        echo ""
        echo "Running processes:"
        ps aux | grep "tlc2.TLC" | grep -v grep || echo "No TLC processes running"
        ;;
    6)
        echo "Select log to monitor:"
        echo "1) 4-Node Safety"
        echo "2) 10-Node Safety"
        echo "3) Resilience Test"
        read -p "Enter choice [1-3]: " log_choice
        
        case $log_choice in
            1) tail -f verification_4node_final.log ;;
            2) tail -f verification_10nodes.log ;;
            3) tail -f verification_resilience.log ;;
            *) echo "Invalid choice" ;;
        esac
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "========================================="
echo "Test Management Commands:"
echo "========================================="
echo "Monitor progress:  tail -f verification_*.log"
echo "Check processes:   ps aux | grep tlc2.TLC"
echo "Stop test:         kill <PID>"
echo "Check disk space:  df -h /System/Volumes/Data"
echo ""

