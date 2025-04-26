#!/bin/bash

# passive and usefull tool to find the subdomains after not getting success you can run active tools like puredns/amass active scan
# Usage: ./subenum_bulk.sh domains.txt

if [ $# -eq 0 ]; then
    echo "Usage: $0 <domain_list_file>"
    exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE="subdomains.txt"

# Clear previous results as well as checking if the subdomains.txt file already exits.
> "$OUTPUT_FILE"

echo "[+] Processing domains from: $INPUT_FILE"
echo "[+] Results will be saved to: $OUTPUT_FILE"
echo "----------------------------------------"

while read -r DOMAIN; do
    if [ -z "$DOMAIN" ]; then
        continue
    fi

    echo "[+] Enumerating: $DOMAIN"
    
   
    subfinder -d "$DOMAIN" -silent >> "$OUTPUT_FILE"
    assetfinder --subs-only "$DOMAIN" >> "$OUTPUT_FILE"
    amass enum -passive -d "$DOMAIN" >> "$OUTPUT_FILE"
    curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' >> "$OUTPUT_FILE"

    echo "[+] Finished $DOMAIN"
    echo "----------------------------------------"
done < "$INPUT_FILE"


echo "[+] Cleaning and sorting results..."
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

COUNT=$(wc -l < "$OUTPUT_FILE")
echo "[+] Done! Found $COUNT unique subdomains total"
echo "[+] Results saved to: $OUTPUT_FILE"
