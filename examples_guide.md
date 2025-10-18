# ComboGen 2.0 - Complete Examples Guide 📚

This guide explains **every command-line flag** with practical examples and use cases.

---

## Table of Contents

1. [Basic Syntax](#basic-syntax)
2. [Required Arguments](#required-arguments)
3. [Optional Flags](#optional-flags)
4. [Real-World Examples](#real-world-examples)
5. [Common Patterns](#common-patterns)

---

## Basic Syntax

```bash
combo_gen_hybrid <LENGTH> [FLAGS]
```

**Structure:**
- `combo_gen_hybrid` - The program name
- `<LENGTH>` - **Required**: How long each combination should be
- `[FLAGS]` - **Optional**: Additional options to control behavior

---

## Required Arguments

### `<LENGTH>` - Combination Length

**What it does:** Sets how many characters each combination will have.

**Type:** Positive integer (1, 2, 3, 4, ...)

**Examples:**

```bash
# Generate all 3-character combinations
combo_gen_hybrid 3

# Result: "!!!", "!!\", "!!#", ..., "~~~"
# With default charset (ASCII 33-126), this creates 94^3 = 830,584 combinations
```

```bash
# Generate all 8-character combinations
combo_gen_hybrid 8

# Result: "!!!!!!!!", "!!!!!!\", ..., "~~~~~~~~"
# With default charset: 94^8 = 6,095,689,385,410,816 combinations
```

```bash
# Generate 1-character combinations
combo_gen_hybrid 1

# Result: "!", "\", "#", "$", ..., "~"
# 94 total combinations
```

**Understanding the math:**
- Length 1: 94 combinations
- Length 2: 94 × 94 = 8,836 combinations
- Length 3: 94 × 94 × 94 = 830,584 combinations
- Length 4: 94^4 = 78,074,896 combinations
- Length 8: 94^8 = 6+ quadrillion combinations

---

## Optional Flags

### `--limit N` - Limit Total Combinations

**What it does:** Stops generating after creating N combinations instead of generating all possible combinations.

**Type:** Positive integer

**Why use it:** 
- Testing without creating huge files
- Generating sample data
- Controlling resource usage
- Quick benchmarks

**Examples:**

```bash
# Generate only 1,000 combinations (instead of all 830,584)
combo_gen_hybrid 3 --limit 1000

# Result: First 1,000 combinations only
```

```bash
# Generate 100,000 combinations of length 8
combo_gen_hybrid 8 --limit 100000

# Without --limit: Would create 6+ quadrillion combinations (HUGE!)
# With --limit: Creates exactly 100,000 combinations (manageable)
```

```bash
# Generate 50 combinations for quick testing
combo_gen_hybrid 5 --limit 50

# Perfect for testing before running a large job
```

**Real-world scenario:**
```bash
# Bad: This would take years and fill your disk!
combo_gen_hybrid 10

# Good: Generate a reasonable subset for testing
combo_gen_hybrid 10 --limit 1000000  # 1 million combinations
```

---

### `--threads N` - CPU Thread Count

**What it does:** Controls how many CPU threads (parallel workers) the program uses.

**Type:** Positive integer (1, 2, 4, 8, 16, 32, ...)

**Default:** Uses all available CPU cores

**Why use it:**
- Maximum speed: Use all cores
- Leave resources for other tasks: Use fewer cores
- Testing: Use single thread for debugging

**Examples:**

```bash
# Use 8 CPU threads
combo_gen_hybrid 8 --limit 1000000 --threads 8

# Good for: Systems with 8+ cores, leaving some for other tasks
```

```bash
# Use single thread (slowest but uses least resources)
combo_gen_hybrid 6 --limit 100000 --threads 1

# Good for: Debugging, not slowing down other programs
```

```bash
# Use 32 threads (maximum performance on high-core CPUs)
combo_gen_hybrid 8 --limit 10000000 --threads 32

# Good for: AMD Ryzen 9 7950X (32 threads), Intel i9-13900K (32 threads)
```

```bash
# Use 4 threads on a laptop
combo_gen_hybrid 6 --threads 4

# Good for: Laptop with 4-core CPU, balanced performance/battery
```

**How to choose:**

| CPU Type | Threads | Example |
|----------|---------|---------|
| Laptop (4-core) | 4 | `--threads 4` |
| Desktop (8-core) | 8-16 | `--threads 8` |
| Workstation (16-core) | 16-32 | `--threads 16` |
| Server (32+ core) | 32-64 | `--threads 32` |

**Check your CPU cores:**
```bash
# Linux/Mac
nproc

# Windows (PowerShell)
$env:NUMBER_OF_PROCESSORS
```

---

### `--output <PATH>` - Output File Path

**What it does:** Specifies where to save the generated combinations.

**Type:** File path (relative or absolute)

**Default:** `combos.txt` in current directory

**Examples:**

```bash
# Save to custom file
combo_gen_hybrid 6 --limit 10000 --output passwords.txt

# Creates: passwords.txt in current directory
```

```bash
# Save to specific directory
combo_gen_hybrid 8 --limit 100000 --output /home/user/data/combos.txt

# Creates: /home/user/data/combos.txt
```

```bash
# Save with timestamp in filename
combo_gen_hybrid 7 --limit 50000 --output "combos_$(date +%Y%m%d_%H%M%S).txt"

# Creates: combos_20250118_143022.txt
```

```bash
# Save to temporary directory
combo_gen_hybrid 5 --limit 1000 --output /tmp/test_combos.txt

# Good for: Testing, temporary data
```

**File format:** Plain text, one combination per line
```
abc
abd
abe
abf
...
```

---

### `--charset <CHARACTERS>` - Custom Character Set

**What it does:** Specifies which characters to use for generating combinations.

**Type:** String of characters

**Default:** ASCII printable characters (33-126): `!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~`

**Examples:**

```bash
# Use only lowercase letters
combo_gen_hybrid 4 --charset "abcdefghijklmnopqrstuvwxyz"

# Result: "aaaa", "aaab", "aaac", ..., "zzzz"
# Total: 26^4 = 456,976 combinations
```

```bash
# Use only numbers (0-9)
combo_gen_hybrid 6 --charset "0123456789"

# Result: "000000", "000001", "000002", ..., "999999"
# Total: 10^6 = 1,000,000 combinations
# Good for: PINs, numeric codes
```

```bash
# Mix letters and numbers
combo_gen_hybrid 8 --charset "abcdefghijklmnopqrstuvwxyz0123456789"

# Result: Alphanumeric combinations
# Total: 36^8 = 2,821,109,907,456 combinations
```

```bash
# Use only specific characters
combo_gen_hybrid 5 --charset "abc123"

# Result: Only uses 'a', 'b', 'c', '1', '2', '3'
# Total: 6^5 = 7,776 combinations
```

```bash
# DNA sequences
combo_gen_hybrid 10 --charset "ACTG"

# Result: "AAAAAAAAAA", "AAAAAAAAAC", ..., "GGGGGGGGGG"
# Total: 4^10 = 1,048,576 combinations
```

```bash
# Binary combinations
combo_gen_hybrid 8 --charset "01"

# Result: "00000000", "00000001", ..., "11111111"
# Total: 2^8 = 256 combinations
```

```bash
# Hexadecimal
combo_gen_hybrid 16 --charset "0123456789abcdef"

# Result: 16-character hex strings
# Total: 16^16 = 18,446,744,073,709,551,616 combinations
```

**Special characters:**
```bash
# Include special symbols
combo_gen_hybrid 8 --charset "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()"

# Good for: Password generation
```

---

### `--resume <PATH>` - Resume File Path

**What it does:** Allows restarting an interrupted generation from where it stopped.

**Type:** File path to resume state file

**How it works:** 
1. Program saves progress every 100,000 combinations
2. If interrupted, restart with same command
3. Program continues from last saved position

**Examples:**

```bash
# Start with resume tracking
combo_gen_hybrid 8 --limit 10000000 --resume progress.txt

# If interrupted, run exact same command to continue
combo_gen_hybrid 8 --limit 10000000 --resume progress.txt
```

```bash
# Large job with resume capability
combo_gen_hybrid 10 --limit 100000000 --resume /home/user/job_state.txt --output bigfile.txt

# Can safely stop and restart anytime
```

**Real-world scenario:**
```bash
# Day 1: Start large job
combo_gen_hybrid 9 --limit 50000000 --resume state.txt --output data.txt
# ... runs for 6 hours, then power outage ...

# Day 2: Resume exactly where it stopped
combo_gen_hybrid 9 --limit 50000000 --resume state.txt --output data.txt
# Continues from combination #27,345,891
```

**Resume file content:**
```
27345891
```
Just contains the index of last generated combination.

---

### `--compress <TYPE>` - Output Compression

**What it does:** Compresses output file to save disk space.

**Type:** `gzip` or `none`

**Default:** `none` (no compression)

**Compression ratio:** Typically 70-90% smaller files

**Examples:**

```bash
# Enable gzip compression
combo_gen_hybrid 8 --limit 1000000 --compress gzip --output combos.txt.gz

# Without compression: ~9 MB file
# With gzip: ~1-2 MB file (80% smaller!)
```

```bash
# No compression (faster, larger files)
combo_gen_hybrid 8 --limit 1000000 --compress none --output combos.txt

# Or simply omit --compress flag
combo_gen_hybrid 8 --limit 1000000 --output combos.txt
```

**When to use compression:**
- ✅ Large files (> 100 MB)
- ✅ Long-term storage
- ✅ Limited disk space
- ✅ Network transfer
- ❌ Need immediate access (decompression takes time)
- ❌ Further processing required

**Decompressing files:**
```bash
# Extract compressed file
gunzip combos.txt.gz

# Or read directly without extracting
zcat combos.txt.gz | head -10
```

---

### `--cpu-only` - Disable GPU

**What it does:** Forces program to use only CPU, disabling GPU acceleration.

**Type:** Boolean flag (no value needed)

**Why use it:**
- GPU not available
- GPU drivers not installed
- Small jobs (< 1M combinations) where CPU is faster
- Testing CPU performance
- Saving GPU for other tasks

**Examples:**

```bash
# Use only CPU
combo_gen_hybrid 8 --limit 100000 --cpu-only

# Good for: Small jobs, no GPU available
```

```bash
# CPU with maximum threads
combo_gen_hybrid 7 --limit 500000 --cpu-only --threads 32

# Good for: High-core CPU systems, GPU busy with other tasks
```

```bash
# Quick test with CPU
combo_gen_hybrid 5 --limit 10000 --cpu-only --dry-run

# Good for: Testing without GPU overhead
```

**Performance comparison:**
```bash
# Small job (100K combinations): CPU is faster
combo_gen_hybrid 6 --limit 100000 --cpu-only
# Time: ~2 seconds

combo_gen_hybrid 6 --limit 100000 --gpu-only
# Time: ~4 seconds (GPU overhead not worth it)

# Large job (10M combinations): GPU is faster
combo_gen_hybrid 8 --limit 10000000 --cpu-only
# Time: ~180 seconds

combo_gen_hybrid 8 --limit 10000000 --gpu-only
# Time: ~45 seconds (GPU shines here!)
```

---

### `--gpu-only` - Disable CPU Threads

**What it does:** Forces program to use only GPU, disabling CPU worker threads.

**Type:** Boolean flag (no value needed)

**Why use it:**
- Maximum GPU performance
- Large jobs (> 10M combinations)
- Benchmarking GPU speed
- CPU needed for other tasks

**Examples:**

```bash
# Use only GPU
combo_gen_hybrid 8 --limit 10000000 --gpu-only

# Best for: Large jobs, powerful GPU (RTX 4090, etc.)
```

```bash
# Maximum GPU performance
combo_gen_hybrid 9 --limit 50000000 --gpu-only --output bigdata.txt

# Good for: Batch processing, dedicated GPU server
```

```bash
# GPU benchmark
combo_gen_hybrid 8 --limit 1000000 --gpu-only --dry-run

# Tests pure GPU speed without file I/O
```

**When to use:**

| Job Size | Best Mode | Example |
|----------|-----------|---------|
| < 1M | CPU-only | `--cpu-only` |
| 1M - 10M | Hybrid (default) | (no flag) |
| > 10M | GPU-only | `--gpu-only` |

---

### `--verbose` - Detailed Output

**What it does:** Shows detailed progress information and debug messages.

**Type:** Boolean flag (no value needed)

**Default:** Normal output (minimal logging)

**Examples:**

```bash
# Enable verbose mode
combo_gen_hybrid 8 --limit 100000 --verbose

# Output:
# Thread 0 started: range 0-12500
# Thread 1 started: range 12500-25000
# ...
# Thread 0 completed: 12500 combinations
# Thread 1 completed: 12500 combinations
```

```bash
# Verbose with resume
combo_gen_hybrid 8 --limit 1000000 --resume state.txt --verbose

# Output shows:
# Resuming from index: 345678
# Resume state saved: 445678
# Resume state saved: 545678
```

```bash
# Verbose for debugging
combo_gen_hybrid 6 --limit 10000 --cpu-only --verbose

# Shows thread allocation, buffer flushing, timing details
```

**Output comparison:**

**Normal mode:**
```
Generated: 100,000 combinations
Time: 3.2s
Throughput: 31,250 combos/sec
```

**Verbose mode:**
```
Thread 0 started: processing 25,000 combinations
Thread 1 started: processing 25,000 combinations
Thread 2 started: processing 25,000 combinations
Thread 3 started: processing 25,000 combinations
Buffer flush: 1 MB written
Thread 0 completed: 25,000 combinations
Thread 1 completed: 25,000 combinations
Buffer flush: 1 MB written
Thread 2 completed: 25,000 combinations
Thread 3 completed: 25,000 combinations
Final flush: 384 KB written
Generated: 100,000 combinations
Time: 3.2s
Throughput: 31,250 combos/sec
```

---

### `--dry-run` - No File Output

**What it does:** Runs the generation process but doesn't write any output file. Used for benchmarking pure speed.

**Type:** Boolean flag (no value needed)

**Why use it:**
- Performance testing
- Benchmarking CPU/GPU speed
- Testing without filling disk
- Comparing different configurations

**Examples:**

```bash
# Benchmark performance without I/O overhead
combo_gen_hybrid 8 --limit 1000000 --dry-run

# Generates combinations in memory but doesn't write to disk
# Shows pure generation speed
```

```bash
# Compare CPU vs GPU speed
combo_gen_hybrid 8 --limit 5000000 --cpu-only --dry-run
# Time: 45 seconds

combo_gen_hybrid 8 --limit 5000000 --gpu-only --dry-run
# Time: 12 seconds

# GPU is 3.75x faster!
```

```bash
# Test thread scaling
combo_gen_hybrid 7 --limit 1000000 --threads 4 --dry-run --verbose
combo_gen_hybrid 7 --limit 1000000 --threads 8 --dry-run --verbose
combo_gen_hybrid 7 --limit 1000000 --threads 16 --dry-run --verbose

# Compare throughput across different thread counts
```

**When to use:**
- ✅ Performance testing
- ✅ Configuration tuning
- ✅ System benchmarking
- ❌ Actual data generation (use normal mode)

---

## Real-World Examples

### Example 1: Quick Test

**Goal:** Test the program with a small dataset

```bash
combo_gen_hybrid 4 --limit 1000 --output test.txt --verbose
```

**Explanation:**
- `4` - Generate 4-character combinations
- `--limit 1000` - Only create 1,000 combinations (not all 78 million)
- `--output test.txt` - Save to test.txt
- `--verbose` - Show detailed progress

**Result:** test.txt with 1,000 lines like:
```
!!!!
!!!"
!!!\
!!!#
...
```

---

### Example 2: Password Dictionary

**Goal:** Create a password dictionary for security testing

```bash
combo_gen_hybrid 8 \
    --charset "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()" \
    --limit 10000000 \
    --output passwords.txt.gz \
    --compress gzip \
    --gpu-only \
    --verbose
```

**Explanation:**
- `8` - 8-character passwords
- `--charset "..."` - Letters (upper/lower), numbers, special chars
- `--limit 10000000` - Generate 10 million passwords
- `--output passwords.txt.gz` - Compressed output file
- `--compress gzip` - Enable compression (saves ~80% disk space)
- `--gpu-only` - Use GPU for maximum speed
- `--verbose` - Show progress details

**Time:** ~45 seconds on RTX 4090  
**File size:** ~90 MB compressed (vs ~800 MB uncompressed)

---

### Example 3: DNA Sequence Analysis

**Goal:** Generate all possible DNA sequences of length 12

```bash
combo_gen_hybrid 12 \
    --charset "ACTG" \
    --limit 5000000 \
    --output dna_sequences.txt \
    --threads 16 \
    --resume dna_progress.txt
```

**Explanation:**
- `12` - 12-nucleotide sequences
- `--charset "ACTG"` - Only use A, C, T, G (DNA bases)
- `--limit 5000000` - Generate 5 million sequences
- `--output dna_sequences.txt` - Save sequences
- `--threads 16` - Use 16 CPU threads
- `--resume dna_progress.txt` - Enable resume (job may take hours)

**Total possible:** 4^12 = 16,777,216 sequences  
**Time:** ~8 minutes on 16-core CPU

---

### Example 4: Hexadecimal Key Generation

**Goal:** Generate cryptographic key candidates

```bash
combo_gen_hybrid 16 \
    --charset "0123456789abcdef" \
    --limit 100000000 \
    --output hex_keys.txt.gz \
    --compress gzip \
    --gpu-only \
    --resume hex_state.txt \
    --verbose
```

**Explanation:**
- `16` - 16-character hex strings (64-bit)
- `--charset "0123456789abcdef"` - Hexadecimal characters
- `--limit 100000000` - 100 million keys
- `--compress gzip` - Compress output
- `--gpu-only` - Maximum GPU speed
- `--resume hex_state.txt` - Resume capability (large job)
- `--verbose` - Monitor progress

**Time:** ~1.5 hours on RTX 4090  
**File size:** ~1.2 GB compressed

---

### Example 5: Quick Benchmark

**Goal:** Test system performance

```bash
# CPU benchmark
combo_gen_hybrid 8 --limit 1000000 --cpu-only --threads 32 --dry-run --verbose

# GPU benchmark
combo_gen_hybrid 8 --limit 1000000 --gpu-only --dry-run --verbose

# Hybrid benchmark
combo_gen_hybrid 8 --limit 1000000 --dry-run --verbose
```

**Explanation:**
- `--dry-run` - No file output (pure speed test)
- `--verbose` - Show detailed timing
- Compare three modes to find fastest

---

### Example 6: Resumable Large Job

**Goal:** Generate 50 million combinations with ability to stop/resume

```bash
combo_gen_hybrid 9 \
    --limit 50000000 \
    --output large_dataset.txt \
    --resume job_state.txt \
    --gpu-only \
    --verbose
```

**If interrupted:**
```bash
# Simply run exact same command
combo_gen_hybrid 9 \
    --limit 50000000 \
    --output large_dataset.txt \
    --resume job_state.txt \
    --gpu-only \
    --verbose

# Will continue from where it stopped
```

**Explanation:**
- `--resume job_state.txt` - Saves progress every 100K combinations
- If stopped (Ctrl+C, power loss, etc.), run same command
- Program reads job_state.txt and continues
- No data loss, no duplicate work

---

## Common Patterns

### Pattern 1: Small Test Before Big Job

```bash
# Step 1: Test with small limit
combo_gen_hybrid 8 --charset "abc123" --limit 100 --output test.txt --verbose

# Step 2: Check output
cat test.txt

# Step 3: Run full job
combo_gen_hybrid 8 --charset "abc123" --output full.txt
```

---

### Pattern 2: Maximum Performance

```bash
# For jobs > 10M combinations
combo_gen_hybrid 8 \
    --limit 50000000 \
    --gpu-only \
    --compress gzip \
    --output data.txt.gz \
    --resume progress.txt
```

---

### Pattern 3: Resource-Constrained System

```bash
# Use fewer threads, compression
combo_gen_hybrid 7 \
    --limit 1000000 \
    --threads 4 \
    --cpu-only \
    --compress gzip \
    --output data.txt.gz
```

---

### Pattern 4: Benchmark Suite

```bash
# Test 1: CPU performance
time combo_gen_hybrid 8 --limit 1000000 --cpu-only --dry-run

# Test 2: GPU performance
time combo_gen_hybrid 8 --limit 1000000 --gpu-only --dry-run

# Test 3: Hybrid performance
time combo_gen_hybrid 8 --limit 1000000 --dry-run

# Compare times to choose best mode
```

---

### Pattern 5: Production Job Template

```bash
#!/bin/bash
# production_job.sh

combo_gen_hybrid 10 \
    --charset "abcdefghijklmnopqrstuvwxyz0123456789" \
    --limit 100000000 \
    --output "/data/output_$(date +%Y%m%d).txt.gz" \
    --compress gzip \
    --resume "/data/state.txt" \
    --gpu-only \
    --verbose \
    2>&1 | tee "/data/log_$(date +%Y%m%d).txt"
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                    ComboGen 2.0 Quick Reference              │
├─────────────────────────────────────────────────────────────┤
│ BASIC                                                        │
│   combo_gen_hybrid 8                    # 8-char combos     │
│   combo_gen_hybrid 8 --limit 100000     # Only 100K         │
│                                                              │
│ CONTROL                                                      │
│   --threads 16          # Use 16 CPU threads                │
│   --cpu-only            # Disable GPU                        │
│   --gpu-only            # Disable CPU workers                │
│                                                              │
│ OUTPUT                                                       │
│   --output file.txt     # Save to file                      │
│   --compress gzip       # Enable compression                │
│                                                              │
│ CHARSET                                                      │
│   --charset "abc123"    # Custom characters                 │
│   --charset "ACTG"      # DNA sequences                     │
│   --charset "01"        # Binary                            │
│                                                              │
│ ADVANCED                                                     │
│   --resume state.txt    # Enable resume                     │
│   --verbose             # Detailed output                   │
│   --dry-run             # Benchmark only                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Need Help?

**Common Issues:**
- "Out of memory" → Use `--limit` with smaller number
- "Slow performance" → Try `--gpu-only` for large jobs
- "File too large" → Use `--compress gzip`
- "Job interrupted" → Use `--resume state.txt`

**Documentation:**
- Full guide: `README.md`
- Benchmarks: Run `./benchmark.sh`
- Issues: https://github.com/chamath-adithya/combo_gen/issues

---

**Last Updated:** 2025-01-18  
**Version:** 2.0.0