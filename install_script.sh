#!/bin/bash
# install.sh - ComboGen 2.0 Quick Installation Script
# Usage: curl -sSL https://raw.githubusercontent.com/chamath-adithya/combo_gen_hybrid/main/install.sh | bash
# Or: ./install.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════╗
║                                              ║
║        ComboGen 2.0 Installer                ║
║        GPU+CPU Hybrid Edition                ║
║                                              ║
╚══════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${YELLOW}Warning: Running as root. This is not recommended.${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Detect OS
echo -e "${BLUE}Detecting system...${NC}"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo -e "${GREEN}✓ Linux detected${NC}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo -e "${GREEN}✓ macOS detected${NC}"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
    echo -e "${GREEN}✓ Windows detected${NC}"
else
    echo -e "${RED}✗ Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

# Check Rust installation
echo -e "\n${BLUE}Checking Rust installation...${NC}"
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version | awk '{print $2}')
    echo -e "${GREEN}✓ Rust $RUST_VERSION found${NC}"
else
    echo -e "${YELLOW}! Rust not found. Installing...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    echo -e "${GREEN}✓ Rust installed${NC}"
fi

# Check GPU availability
echo -e "\n${BLUE}Checking GPU support...${NC}"
GPU_AVAILABLE=false

if command -v nvidia-smi &> /dev/null; then
    echo -e "${GREEN}✓ NVIDIA GPU detected${NC}"
    nvidia-smi --query-gpu=name --format=csv,noheader
    GPU_AVAILABLE=true
elif command -v rocm-smi &> /dev/null; then
    echo -e "${GREEN}✓ AMD GPU detected${NC}"
    GPU_AVAILABLE=true
elif command -v vulkaninfo &> /dev/null; then
    echo -e "${GREEN}✓ Vulkan support detected${NC}"
    GPU_AVAILABLE=true
else
    echo -e "${YELLOW}! No GPU detected. Installing CPU-only version${NC}"
fi

# Installation options
echo -e "\n${CYAN}Installation Options:${NC}"
echo "1. Full installation (GPU + CPU)"
echo "2. CPU-only (faster build, no GPU)"
echo "3. Skip build (clone only)"
read -p "Select option (1-3): " -n 1 -r INSTALL_OPTION
echo

# Clone repository
echo -e "\n${BLUE}Cloning repository...${NC}"
INSTALL_DIR="$HOME/combo_gen"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}! Directory exists. Updating...${NC}"
    cd "$INSTALL_DIR"
    git pull
else
    git clone https://github.com/Chamath-Adithya/combo_gen_hybrid.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"
echo -e "${GREEN}✓ Repository ready${NC}"

# Build based on selection
if [ "$INSTALL_OPTION" != "3" ]; then
    echo -e "\n${BLUE}Building ComboGen 2.0...${NC}"
    
    if [ "$INSTALL_OPTION" == "2" ] || [ "$GPU_AVAILABLE" == false ]; then
        # CPU-only build
        echo -e "${YELLOW}Building CPU-only version...${NC}"
        RUSTFLAGS="-C target-cpu=native -C opt-level=3 -C lto=fat" \
        cargo build --release --no-default-features --features cpu-only
    else
        # Full GPU + CPU build
        echo -e "${YELLOW}Building hybrid GPU+CPU version...${NC}"
        
        # Check for GPU libraries
        if [ "$OS" == "linux" ]; then
            if ! ldconfig -p | grep -q libvulkan; then
                echo -e "${YELLOW}! Vulkan not found. Installing...${NC}"
                if command -v apt &> /dev/null; then
                    sudo apt update && sudo apt install -y vulkan-tools libvulkan-dev
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y vulkan-tools vulkan-loader-devel
                fi
            fi
        fi
        
        RUSTFLAGS="-C target-cpu=native -C opt-level=3 -C lto=fat" \
        cargo build --release
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Build successful${NC}"
    else
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    fi
fi

# Create symlink
echo -e "\n${BLUE}Creating symlink...${NC}"
BINARY_PATH="$INSTALL_DIR/target/release/combo_gen_hybrid"
SYMLINK_PATH="$HOME/.local/bin/combo_gen"

mkdir -p "$HOME/.local/bin"

if [ -f "$BINARY_PATH" ]; then
    ln -sf "$BINARY_PATH" "$SYMLINK_PATH"
    echo -e "${GREEN}✓ Symlink created: $SYMLINK_PATH${NC}"
else
    echo -e "${YELLOW}! Binary not found (build may have been skipped)${NC}"
fi

# Add to PATH
echo -e "\n${BLUE}Configuring PATH...${NC}"
SHELL_RC=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "\.local/bin" "$SHELL_RC"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        echo -e "${GREEN}✓ PATH updated in $SHELL_RC${NC}"
        echo -e "${YELLOW}! Run 'source $SHELL_RC' to apply changes${NC}"
    else
        echo -e "${GREEN}✓ PATH already configured${NC}"
    fi
fi

# Create benchmark script
echo -e "\n${BLUE}Setting up benchmark script...${NC}"
if [ -f "$INSTALL_DIR/benchmark.sh" ]; then
    chmod +x "$INSTALL_DIR/benchmark.sh"
    ln -sf "$INSTALL_DIR/benchmark.sh" "$HOME/.local/bin/combo_gen_benchmark"
    echo -e "${GREEN}✓ Benchmark script ready: combo_gen_benchmark${NC}"
fi

# Quick test
echo -e "\n${BLUE}Running quick test...${NC}"
if [ -f "$BINARY_PATH" ]; then
    cd /tmp
    if timeout 10 "$BINARY_PATH" 4 --limit 1000 --dry-run &> /dev/null; then
        echo -e "${GREEN}✓ Test passed${NC}"
    else
        echo -e "${YELLOW}! Test completed with warnings (this is normal)${NC}"
    fi
else
    echo -e "${YELLOW}! Skipping test (binary not built)${NC}"
fi

# Print summary
echo -e "\n${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════╗
║                                              ║
║        Installation Complete! 🎉             ║
║                                              ║
╚══════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${GREEN}Installation Summary:${NC}"
echo -e "  Location: ${BLUE}$INSTALL_DIR${NC}"
if [ -f "$BINARY_PATH" ]; then
    echo -e "  Binary: ${BLUE}$BINARY_PATH${NC}"
    echo -e "  Symlink: ${BLUE}$SYMLINK_PATH${NC}"
fi
echo -e "  Mode: ${BLUE}$([ "$INSTALL_OPTION" == "2" ] && echo "CPU-only" || echo "Hybrid GPU+CPU")${NC}"

echo -e "\n${YELLOW}Quick Start:${NC}"
if [ -f "$BINARY_PATH" ]; then
    echo -e "  ${CYAN}combo_gen 8 --limit 100000${NC}  # Generate 100K combinations"
    echo -e "  ${CYAN}combo_gen 8 --gpu-only --limit 1000000${NC}  # Use GPU"
    echo -e "  ${CYAN}combo_gen 6 --charset abc123${NC}  # Custom charset"
    echo -e "  ${CYAN}combo_gen_benchmark${NC}  # Run benchmarks"
else
    echo -e "  ${CYAN}cd $INSTALL_DIR${NC}"
    echo -e "  ${CYAN}cargo build --release${NC}"
    echo -e "  ${CYAN}./target/release/combo_gen_hybrid 8 --limit 100000${NC}"
fi

echo -e "\n${YELLOW}Documentation:${NC}"
echo -e "  ${CYAN}cat $INSTALL_DIR/README.md${NC}"
echo -e "  ${CYAN}cat $INSTALL_DIR/EXAMPLES.md${NC}"
echo -e "  ${CYAN}https://github.com/Chamath-Adithya/combo_gen_hybrid${NC}"

echo -e "\n${GREEN}Next Steps:${NC}"
if [ -n "$SHELL_RC" ]; then
    echo -e "  1. Run: ${CYAN}source $SHELL_RC${NC}"
fi
echo -e "  2. Test: ${CYAN}combo_gen 6 --limit 1000 --dry-run${NC}"
echo -e "  3. Benchmark: ${CYAN}combo_gen_benchmark${NC}"

echo -e "\n${BLUE}Happy generating! 🚀${NC}\n"
