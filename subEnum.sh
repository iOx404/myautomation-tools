#!/bin/bash


# Usage: ./subdomain_scan.sh domains.txt output.txt

# Check if required tools are installed
check_tools() {
    tools=("subfinder" "assetfinder" "amass" "curl" "jq")
    missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "The following tools are missing:"
        for missing in "${missing_tools[@]}"; do
            echo " - $missing"
        done
        echo "Please install them before running this script."
        exit 1
    fi
}

# Check for correct arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <domains_file> <output_file>"
    exit 1
fi

domains_file=$1
output_file=$2

# Check if domains file exists
if [ ! -f "$domains_file" ]; then
    echo "Error: Domains file '$domains_file' not found."
    exit 1
fi

# Check tools before proceeding
check_tools

# Create temporary directory
temp_dir=$(mktemp -d)
echo "Using temporary directory: $temp_dir"

# Function to fetch subdomains from crt.sh
fetch_crtsh() {
    domain=$1
    echo "[+] Checking crt.sh for $domain"
    curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u >> "$temp_dir/$domain-subs.txt"
}

# Process each domain
while IFS= read -r domain || [[ -n "$domain" ]]; do
    if [ -z "$domain" ]; then
        continue
    fi
    
    echo "Processing domain: $domain"
    
    # Run subfinder
    echo "[+] Running Subfinder"
    subfinder -d "$domain" -silent >> "$temp_dir/$domain-subs.txt"
    
    # Run assetfinder
    echo "[+] Running Assetfinder"
    assetfinder --subs-only "$domain" >> "$temp_dir/$domain-subs.txt"
    
    # Run amass in passive mode first
    echo "[+] Running Amass (passive)"
    amass enum -passive -d "$domain" >> "$temp_dir/$domain-subs.txt"
    
    # Run amass with resolver (active mode)
    echo "[+] Running Amass with resolver (active)"
    amass enum -active -d "$domain" -brute -w /usr/share/amass/wordlists/all.txt -rf /home/i0/.config/puredns/resolvers.txt -oA "$temp_dir/$domain-amass"
    cat "$temp_dir/$domain-amass.txt" >> "$temp_dir/$domain-subs.txt"
    
    # Check certificate transparency
    fetch_crtsh "$domain"
    
    # Sort and deduplicate
    sort -u "$temp_dir/$domain-subs.txt" -o "$temp_dir/$domain-subs.txt"
    
    # Count results
    count=$(wc -l < "$temp_dir/$domain-subs.txt")
    echo "[+] Found $count unique subdomains for $domain"
    
    # Append to final output
    cat "$temp_dir/$domain-subs.txt" >> "$temp_dir/all-subs.txt"
done < "$domains_file"

# Final deduplication and sorting
echo "[+] Final processing of all results"
sort -u "$temp_dir/all-subs.txt" -o "$output_file"
total=$(wc -l < "$output_file")

echo "===================================="
echo "Subdomain enumeration complete!"
echo "Total unique subdomains found: $total"
echo "Results saved to: $output_file"

# Clean up
rm -rf "$temp_dir"
