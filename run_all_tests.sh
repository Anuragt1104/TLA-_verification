#!/bin/bash
# Master Test Runner - Complete Alpenglow Verification Reproduction
# This script reproduces all verification results from scratch

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Find TLA+ tools
TLATOOLS=$(find ~/.cursor/extensions -name "tla2tools.jar" 2>/dev/null | head -1)
if [ -z "$TLATOOLS" ]; then
    echo -e "${RED}Error: tla2tools.jar not found${NC}"
    echo "Please install TLA+ Toolbox VS Code extension"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Alpenglow Formal Verification Suite${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "TLA+ Tools: $TLATOOLS"
echo "Working Directory: $SCRIPT_DIR"
echo ""

# Check disk space
DISK_FREE=$(df /System/Volumes/Data | tail -1 | awk '{print $4}')
echo "Available disk space: ${DISK_FREE}GB"
if [ $DISK_FREE -lt 10 ]; then
    echo -e "${YELLOW}Warning: Less than 10GB free! Tests may fail.${NC}"
    echo "Recommended: Free up space before continuing"
    read -p "Continue anyway? [y/N]: " confirm
    [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Suite${NC}"
echo -e "${BLUE}========================================${NC}"
echo "1) Quick 4-Node Safety Test (~2 hours)"
echo "2) Comprehensive 6-Node Test (~6-8 hours)"
echo "3) Statistical Liveness Test (~1 minute)"
echo "4) All Tests Sequentially"
echo "5) Check Running Tests"
echo "6) Quit"
echo ""
read -p "Select test(s) to run [1-6]: " choice

run_test() {
    local config=$1
    local name=$2
    local workers=$3
    local memory=$4
    local logfile=$5
    local extra_flags=$6
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$name${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo "Configuration: $config"
    echo "Workers: $workers"
    echo "Memory: $memory"
    echo "Log: $logfile"
    echo "Started: $(date)"
    echo ""
    
    java -XX:+UseParallelGC -Xmx${memory} \
        -cp "$TLATOOLS" \
        tlc2.TLC -cleanup -workers $workers -deadlock $extra_flags \
        -config "$config" \
        1_Protocol_Modeling/Alpenglow.tla > "$logfile" 2>&1
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ $name: PASSED${NC}"
        echo "Completed: $(date)"
        echo "Results: $logfile"
    else
        echo -e "${RED}❌ $name: FAILED${NC}"
        echo "Check $logfile for errors"
        return 1
    fi
    
    echo ""
    return 0
}

run_simulation() {
    local config=$1
    local name=$2
    local logfile=$3
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$name${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo "Configuration: $config"
    echo "Mode: Simulation (statistical)"
    echo "Traces: 1,000,000"
    echo "Depth: 50"
    echo "Log: $logfile"
    echo ""
    
    java -Xmx6g -cp "$TLATOOLS" \
        tlc2.TLC -simulate num=1000000 -depth 50 -workers 2 \
        -config "$config" \
        1_Protocol_Modeling/Alpenglow.tla > "$logfile" 2>&1
    
    echo -e "${GREEN}✅ $name: Completed${NC}"
    echo "Results: $logfile"
    echo ""
}

check_status() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Test Status${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    if ps aux | grep "[t]lc2.TLC" > /dev/null; then
        echo -e "${YELLOW}Running processes:${NC}"
        ps aux | grep "[t]lc2.TLC" | awk '{print $2, $11, $12, $13, $14, $15}'
    else
        echo "No tests currently running"
    fi
    
    echo ""
    echo -e "${BLUE}Log files:${NC}"
    for log in 2_Safety_Properties/*.log 3_Liveness_Properties/*.log verification_comprehensive*.log 2>/dev/null; do
        if [ -f "$log" ]; then
            size=$(du -h "$log" | awk '{print $1}')
            echo "  $log ($size)"
        fi
    done
    echo ""
}

case $choice in
    1)
        echo "Running Quick 4-Node Safety Test..."
        run_test "2_Safety_Properties/Alpenglow.cfg" \
                 "4-Node Safety Test" \
                 2 \
                 "4g" \
                 "2_Safety_Properties/verification_4node_new.log" \
                 ""
        ;;
    2)
        echo "Running Comprehensive 6-Node Test..."
        echo -e "${YELLOW}Note: This will take 6-8 hours${NC}"
        read -p "Continue? [y/N]: " confirm
        if [[ $confirm == [yY] ]]; then
            run_test "Alpenglow_comprehensive.cfg" \
                     "6-Node Comprehensive Test" \
                     4 \
                     "8g" \
                     "verification_comprehensive_6node.log" \
                     ""
        fi
        ;;
    3)
        echo "Running Statistical Liveness Test..."
        run_simulation "3_Liveness_Properties/Alpenglow_liveness_statistical.cfg" \
                      "Statistical Liveness Test" \
                      "3_Liveness_Properties/liveness_simulation_new.log"
        ;;
    4)
        echo "Running All Tests Sequentially..."
        echo -e "${YELLOW}Total estimated time: 8-10 hours${NC}"
        read -p "Continue? [y/N]: " confirm
        if [[ $confirm == [yY] ]]; then
            run_test "2_Safety_Properties/Alpenglow.cfg" \
                     "4-Node Safety Test" \
                     2 "4g" \
                     "2_Safety_Properties/verification_4node_new.log" \
                     "" && \
            run_simulation "3_Liveness_Properties/Alpenglow_liveness_statistical.cfg" \
                          "Statistical Liveness Test" \
                          "3_Liveness_Properties/liveness_simulation_new.log" && \
            run_test "Alpenglow_comprehensive.cfg" \
                     "6-Node Comprehensive Test" \
                     4 "8g" \
                     "verification_comprehensive_6node.log" \
                     ""
            
            echo ""
            echo -e "${GREEN}========================================${NC}"
            echo -e "${GREEN}All Tests Completed!${NC}"
            echo -e "${GREEN}========================================${NC}"
            echo "Check log files for detailed results"
        fi
        ;;
    5)
        check_status
        ;;
    6)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Useful Commands${NC}"
echo -e "${BLUE}========================================${NC}"
echo "Monitor progress:  tail -f <logfile>"
echo "Check processes:   ps aux | grep tlc2.TLC"
echo "Check disk space:  df -h /System/Volumes/Data"
echo "Kill process:      kill <PID>"
echo ""


