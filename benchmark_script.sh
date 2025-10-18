#!/bin/bash
# benchmark.sh - ComboGen 2.0 Performance Benchmark Suite
# Usage: ./benchmark.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BINARY="./target/release/combo_gen_hybrid"
RESULTS_DIR="benchmark_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="${RESULTS_DIR}/benchmark_${TIMESTAMP}.log"

# Check if binary exists
if [ ! -f "$BINARY" ]; then
    echo -e "${RED}Error: Binary not found. Building...${NC}"
    RUSTFLAGS="-C target-cpu=native -C opt-level=3 -C lto=fat" cargo build --release
fi

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   ComboGen 2.0 Benchmark Suite        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# System info
echo -e "${GREEN}System Information:${NC}"
echo "CPU: $(lscpu | grep 'Model name' | cut -d ':' -f2 | xargs)"
echo "Cores: $(nproc)"
echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
if command -v nvidia-smi &> /dev/null; then
    echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader)"
else
    echo "GPU: Not detected"
fi
echo ""

# Function to run benchmark
run_benchmark() {
    local name=$1
    local length=$2
    local limit=$3
    local flags=$4
    
    echo -e "${YELLOW}Running: $name${NC}"
    echo "  Length: $length, Limit: $limit, Flags: $flags"
    
    # Clean up previous output
    rm -f combos.txt combos.txt.gz
    
    # Run benchmark
    local start=$(date +%s.%N)
    $BINARY $length --limit $limit $flags --dry-run > /dev/null 2>&1
    local end=$(date +%s.%N)
    
    local elapsed=$(echo "$end - $start" | bc)
    local throughput=$(echo "scale=2; $limit / $elapsed / 1000000" | bc)
    
    echo "  Time: ${elapsed}s"
    echo "  Throughput: ${throughput}M combos/sec"
    echo ""
    
    # Log results
    echo "$name,$length,$limit,$flags,$elapsed,$throughput" >> "$RESULTS_FILE"
}

# Initialize results file
echo "Test,Length,Limit,Flags,Time(s),Throughput(M/s)" > "$RESULTS_FILE"

# Benchmark Suite
echo -e "${GREEN}Starting Benchmark Suite...${NC}"
echo ""

# 1. CPU-only tests
echo -e "${BLUE}=== CPU-Only Tests ===${NC}"
run_benchmark "CPU-Small" 6 100000 "--cpu-only --threads $(nproc)"
run_benchmark "CPU-Medium" 7 500000 "--cpu-only --threads $(nproc)"
run_benchmark "CPU-Large" 8 1000000 "--cpu-only --threads $(nproc)"

# 2. GPU-only tests (if GPU available)
if command -v nvidia-smi &> /dev/null || command -v rocm-smi &> /dev/null; then
    echo -e "${BLUE}=== GPU-Only Tests ===${NC}"
    run_benchmark "GPU-Small" 6 100000 "--gpu-only"
    run_benchmark "GPU-Medium" 7 500000 "--gpu-only"
    run_benchmark "GPU-Large" 8 1000000 "--gpu-only"
    run_benchmark "GPU-XLarge" 8 5000000 "--gpu-only"
else
    echo -e "${YELLOW}GPU not detected, skipping GPU tests${NC}"
    echo ""
fi

# 3. Hybrid tests
echo -e "${BLUE}=== Hybrid GPU+CPU Tests ===${NC}"
run_benchmark "Hybrid-Small" 6 100000 "--threads $(nproc)"
run_benchmark "Hybrid-Medium" 7 500000 "--threads $(nproc)"
run_benchmark "Hybrid-Large" 8 1000000 "--threads $(nproc)"
run_benchmark "Hybrid-XLarge" 8 5000000 "--threads $(nproc)"

# 4. Thread scaling tests
echo -e "${BLUE}=== Thread Scaling Tests ===${NC}"
for threads in 1 2 4 8 16 32; do
    if [ $threads -le $(nproc) ]; then
        run_benchmark "CPU-Threads-$threads" 8 100000 "--cpu-only --threads $threads"
    fi
done

# 5. Length scaling tests
echo -e "${BLUE}=== Length Scaling Tests ===${NC}"
run_benchmark "Length-4" 4 1000000 "--cpu-only --threads $(nproc)"
run_benchmark "Length-6" 6 1000000 "--cpu-only --threads $(nproc)"
run_benchmark "Length-8" 8 1000000 "--cpu-only --threads $(nproc)"
run_benchmark "Length-10" 10 100000 "--cpu-only --threads $(nproc)"

# 6. Compression tests
echo -e "${BLUE}=== Compression Tests ===${NC}"
run_benchmark "NoCompress" 8 100000 "--cpu-only --threads $(nproc)"
# Note: compression test writes to file
echo -e "${YELLOW}Running: Compress-gzip${NC}"
local start=$(date +%s.%N)
$BINARY 8 --limit 100000 --compress gzip --output combos.txt.gz --cpu-only --threads $(nproc) > /dev/null 2>&1
local end=$(date +%s.%N)
local elapsed=$(echo "$end - $start" | bc)
echo "  Time: ${elapsed}s"
echo "Compress-gzip,8,100000,--compress gzip,$elapsed,N/A" >> "$RESULTS_FILE"
echo ""

# Generate summary report
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Benchmark Complete!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Results saved to: $RESULTS_FILE"
echo ""

# Display top performers
echo -e "${GREEN}Top Performers:${NC}"
echo ""
tail -n +2 "$RESULTS_FILE" | sort -t',' -k6 -rn | head -n 5 | \
while IFS=',' read -r name length limit flags time throughput; do
    echo "  $name: ${throughput}M combos/sec"
done
echo ""

# Generate visualization data
echo -e "${YELLOW}Generating performance graphs...${NC}"
python3 - <<EOF 2>/dev/null || echo "Install matplotlib for graphs: pip3 install matplotlib"
import csv
import matplotlib.pyplot as plt

# Read data
with open('$RESULTS_FILE', 'r') as f:
    reader = csv.DictReader(f)
    data = list(reader)

# Extract data
names = [row['Test'] for row in data]
throughputs = [float(row['Throughput(M/s)']) if row['Throughput(M/s)'] != 'N/A' else 0 for row in data]

# Create bar chart
plt.figure(figsize=(14, 8))
plt.bar(range(len(names)), throughputs, color='skyblue')
plt.xlabel('Test')
plt.ylabel('Throughput (M combos/sec)')
plt.title('ComboGen 2.0 Performance Benchmark')
plt.xticks(range(len(names)), names, rotation=45, ha='right')
plt.tight_layout()
plt.savefig('${RESULTS_DIR}/benchmark_${TIMESTAMP}.png', dpi=150)
print("Graph saved to: ${RESULTS_DIR}/benchmark_${TIMESTAMP}.png")
EOF

echo ""
echo -e "${GREEN}Benchmark suite completed successfully!${NC}"
echo ""

# Cleanup
rm -f combos.txt combos.txt.gz resume.txt

exit 0