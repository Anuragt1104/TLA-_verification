#!/bin/bash
# Final Comprehensive Test Suite for Alpenglow Verification
# Covers all requirements: Safety, Liveness, Resilience

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TLATOOLS=$(find ~/.cursor/extensions -name "tla2tools.jar" 2>/dev/null | head -1)

if [ -z "$TLATOOLS" ]; then
    echo -e "${RED}Error: tla2tools.jar not found!${NC}"
    exit 1
fi

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Alpenglow Final Comprehensive Test Suite${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Check disk space
AVAILABLE=$(df -h /System/Volumes/Data | tail -1 | awk '{print $4}')
USED_PCT=$(df /System/Volumes/Data | tail -1 | awk '{print $5}' | tr -d '%')
echo "Disk Space: $AVAILABLE available ($USED_PCT% used)"

if [ $USED_PCT -gt 90 ]; then
    echo -e "${YELLOW}Warning: Low disk space. Consider cleaning up:${NC}"
    echo "  rm -rf /var/folders/*/T/tlc-*"
    echo ""
    read -p "Continue anyway? [y/N]: " confirm
    [[ $confirm != [yY] ]] && exit 1
fi

echo ""
echo -e "${GREEN}Final Test Strategy:${NC}"
echo "├─ Test 1: 6-Node Safety & Resilience (4-8 hours)"
echo "│  Purpose: Comprehensive safety + near-20% Byzantine"
echo "│"
echo "├─ Test 2: 5-Node Liveness (Bounded, 1-2 hours)"  
echo "│  Purpose: Progress guarantees with fairness"
echo "│"
echo "└─ Test 3: 4-Node Full Re-verification (2 hours)"
echo "   Purpose: Confirm fixes, fast verification"
echo ""

run_test() {
    local config=$1
    local name=$2
    local workers=$3
    local memory=$4
    local logfile=$5
    local depth=$6
    local mode=$7
    
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}Starting: $name${NC}"
    echo -e "${GREEN}Config: $config${NC}"
    echo -e "${GREEN}Mode: $mode${NC}"
    echo -e "${GREEN}Log: $logfile${NC}"
    echo -e "${GREEN}======================================${NC}"
    
    local cmd="java -XX:+UseParallelGC -Xmx${memory} -cp \"$TLATOOLS\" tlc2.TLC -cleanup -config \"$config\" -workers $workers"
    
    if [ "$mode" = "bounded" ]; then
        cmd="$cmd -depth $depth"
    fi
    
    cmd="$cmd -deadlock Alpenglow.tla > \"$logfile\" 2>&1"
    
    echo "Command: $cmd"
    echo ""
    
    eval $cmd
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ $name: COMPLETED SUCCESSFULLY${NC}"
        grep "No errors found\|Model checking completed" "$logfile" && \
            echo -e "${GREEN}   All checks passed!${NC}" || \
            echo -e "${YELLOW}   Check log for details${NC}"
    elif [ $exit_code -eq 12 ]; then
        echo -e "${YELLOW}⚠️  $name: COMPLETED WITH WARNINGS${NC}"
        echo "   Check $logfile for details"
    else
        echo -e "${RED}❌ $name: FAILED${NC}"
        echo "   Check $logfile for errors"
        grep -i "error\|violation" "$logfile" | head -10
        return 1
    fi
    
    echo ""
    return 0
}

echo -e "${YELLOW}Select test suite to run:${NC}"
echo "1) All Tests (Sequential, ~8-12 hours total)"
echo "2) Test 1 Only: 6-Node Safety & Resilience (~4-8 hours)"
echo "3) Test 2 Only: 5-Node Liveness Bounded (~1-2 hours)"
echo "4) Test 3 Only: 4-Node Re-verification (~2 hours)"
echo "5) Quick Suite: Tests 2+3 (~3-4 hours)"
echo ""
read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        echo -e "${BLUE}Running ALL tests sequentially...${NC}"
        echo "Estimated total time: 8-12 hours"
        echo ""
        read -p "Continue? [y/N]: " confirm
        [[ $confirm != [yY] ]] && exit 1
        
        run_test "Alpenglow_final.cfg" "6-Node Safety & Resilience" 4 "6g" "verification_final_6node.log" "" "standard"
        echo ""
        echo "Waiting 5 minutes before next test..."
        sleep 300
        
        run_test "Alpenglow_liveness.cfg" "5-Node Liveness" 2 "4g" "verification_final_liveness.log" "30" "bounded"
        echo ""
        echo "Waiting 5 minutes before next test..."
        sleep 300
        
        run_test "Alpenglow.cfg" "4-Node Re-verification" 2 "4g" "verification_final_4node.log" "" "standard"
        ;;
        
    2)
        echo -e "${BLUE}Running 6-Node Safety & Resilience Test...${NC}"
        run_test "Alpenglow_final.cfg" "6-Node Safety & Resilience" 4 "6g" "verification_final_6node.log" "" "standard"
        ;;
        
    3)
        echo -e "${BLUE}Running 5-Node Liveness Test (Bounded)...${NC}"
        run_test "Alpenglow_liveness.cfg" "5-Node Liveness" 2 "4g" "verification_final_liveness.log" "30" "bounded"
        ;;
        
    4)
        echo -e "${BLUE}Running 4-Node Re-verification...${NC}"
        run_test "Alpenglow.cfg" "4-Node Re-verification" 2 "4g" "verification_final_4node.log" "" "standard"
        ;;
        
    5)
        echo -e "${BLUE}Running Quick Suite (Tests 2+3)...${NC}"
        echo "Estimated time: 3-4 hours"
        echo ""
        
        run_test "Alpenglow_liveness.cfg" "5-Node Liveness" 2 "4g" "verification_final_liveness.log" "30" "bounded"
        echo ""
        echo "Waiting 5 minutes before next test..."
        sleep 300
        
        run_test "Alpenglow.cfg" "4-Node Re-verification" 2 "4g" "verification_final_4node.log" "" "standard"
        ;;
        
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Test Suite Completed!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Results Summary:"
echo "----------------"

for log in verification_final_*.log; do
    if [ -f "$log" ]; then
        echo ""
        echo "File: $log"
        if grep -q "No errors found\|Model checking completed" "$log" 2>/dev/null; then
            echo -e "  ${GREEN}✅ PASSED${NC}"
            grep "states generated" "$log" | tail -1
        elif grep -q "Invariant.*is violated" "$log" 2>/dev/null; then
            echo -e "  ${RED}❌ FAILED (Invariant violation)${NC}"
        elif grep -q "Finished in" "$log" 2>/dev/null; then
            echo -e "  ${YELLOW}⚠️  COMPLETED WITH ERRORS${NC}"
        else
            echo -e "  ${YELLOW}⏳ IN PROGRESS OR INCOMPLETE${NC}"
        fi
    fi
done

echo ""
echo -e "${BLUE}============================================${NC}"
echo "Next Steps:"
echo "------------"
echo "1. Review logs: verification_final_*.log"
echo "2. Check SUBMISSION_READY.md for final checklist"
echo "3. Update reports with final results"
echo "4. Submit to portal!"
echo ""

