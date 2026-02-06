#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}=== Bruta Fin Protocol ===${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

check_requirements() {
    echo "Checking requirements..."

    if ! command -v gpg &> /dev/null; then
        print_error "gpg not found. Install with: apt install gnupg2 (Debian/Ubuntu) or dnf install gnupg2 (Fedora)"
        exit 1
    fi

    if ! command -v ssss-split &> /dev/null || ! command -v ssss-combine &> /dev/null; then
        print_error "ssss not found. Install with: apt install ssss (Debian/Ubuntu) or dnf install ssss (Fedora)"
        exit 1
    fi

    print_success "All requirements met"
}

setup_protocol() {
    local source_file="$1"
    local encrypted_file="${source_file}.gpg"

    print_header
    echo "Setting up Bruta Fin Protocol..."
    echo ""

    # Step 1: Encrypt the legacy file
    if [[ ! -f "$source_file" ]]; then
        print_error "$source_file not found. Please create it with your digital legacy information."
        exit 1
    fi

    echo "Step 1: Encrypting $source_file with AES256..."
    if gpg --symmetric --cipher-algo AES256 --output "$encrypted_file" "$source_file"; then
        print_success "File encrypted: $encrypted_file"
    else
        print_error "Encryption failed"
        exit 1
    fi
    echo ""

    # Step 2: Split passphrase into shards
    echo "Step 2: Splitting encryption key into 5 shards (any 3 required to recover)..."
    echo "Enter the same passphrase you used above:"
    if ssss-split -t 3 -n 5; then
        print_success "Key split into 5 shards"
    else
        print_error "Key splitting failed"
        exit 1
    fi
    echo ""

    # Step 3: Distribution instructions
    echo "Step 3: Distribution"
    print_warning "KEEP THE SHARDS DISPLAYED ABOVE AND DISTRIBUTE THEM:"
    echo "  - Give the encrypted file ($encrypted_file) to all 5 trusted people"
    echo "  - Give each shard to a different trusted people (include the shard index)"
    echo ""
    print_success "Setup complete! Any 3 people with shards can help you recover your legacy."
}

recovery_protocol() {
    local source_file="$1"
    local encrypted_file="${source_file}.gpg"

    print_header
    echo "Recovering digital legacy..."
    echo ""

    if [[ ! -f "$encrypted_file" ]]; then
        print_error "$encrypted_file not found. Cannot proceed with recovery."
        exit 1
    fi

    # Step 1: Reconstruct key from shards
    echo "Step 1: Reconstructing encryption key from 3 shards..."
    echo "You will be prompted to enter 3 shards (you can obtain these from 3 trusted people), include the shard index"
    echo ""

    if ssss-combine -t 3; then
        print_success "Key reconstructed"
    else
        print_error "Key reconstruction failed"
        exit 1
    fi
    echo ""

    # Step 2: Decrypt the file
    echo "Step 2: Decrypting $encrypted_file..."
    if gpg --decrypt --output "$source_file" "$encrypted_file"; then
        print_success "File decrypted: $source_file"
        echo ""
        print_warning "CAUTION: Your digital legacy is now accessible. Keep it secure!"
    else
        print_error "Decryption failed"
        exit 1
    fi
}

show_usage() {
    echo "Usage: $0 [setup|recover] <filename>"
    echo ""
    echo "Commands:"
    echo "  setup     - Encrypt the file and split key into shards"
    echo "  recover   - Reconstruct key from shards and decrypt the file"
    echo ""
    echo "Arguments:"
    echo "  filename  - Path to the file (e.g., legacy.txt)"
    echo ""
    echo "Example:"
    echo "  $0 setup legacy.txt"
    echo "  $0 recover legacy.txt"
}

# Main script
if [[ $# -lt 2 ]]; then
    show_usage
    exit 0
fi

command="$1"
filename="$2"

case "$command" in
    setup)
        check_requirements
        setup_protocol "$filename"
        ;;
    recover)
        check_requirements
        recovery_protocol "$filename"
        ;;
    *)
        print_error "Unknown command: $command"
        echo ""
        show_usage
        exit 1
        ;;
esac
