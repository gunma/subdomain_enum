#!/bin/bash

# Ensure a domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN=$1
OUTPUT_DIR="subdomain_enum_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/${DOMAIN}_subdomains_${TIMESTAMP}.txt"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Function to combine results and remove duplicates
combine_results() {
    cat $1 | sort -u
}

echo "[*] Starting subdomain enumeration for: $DOMAIN"

# Run subfinder
echo "[*] Running subfinder..."
subfinder -d $DOMAIN -silent -o ${OUTPUT_DIR}/subfinder_${DOMAIN}.txt

# Run amass
echo "[*] Running amass..."
amass enum -d $DOMAIN -o ${OUTPUT_DIR}/amass_${DOMAIN}.txt

# Run assetfinder
echo "[*] Running assetfinder..."
assetfinder --subs-only $DOMAIN > ${OUTPUT_DIR}/assetfinder_${DOMAIN}.txt

# Combine results
echo "[*] Combining results..."
combine_results "${OUTPUT_DIR}/subfinder_${DOMAIN}.txt ${OUTPUT_DIR}/amass_${DOMAIN}.txt ${OUTPUT_DIR}/assetfinder_${DOMAIN}.txt" > ${OUTPUT_FILE}

# Remove potential duplicates
echo "[*] Removing duplicates..."
sort -u ${OUTPUT_FILE} -o ${OUTPUT_FILE}

# Run httprobe to check for live subdomains
echo "[*] Checking for live subdomains with httprobe..."
cat ${OUTPUT_FILE} | httprobe > ${OUTPUT_DIR}/${DOMAIN}_live_subdomains_${TIMESTAMP}.txt

echo "[*] Subdomain enumeration completed."
echo "Results saved in: ${OUTPUT_FILE}"
echo "Live subdomains saved in: ${OUTPUT_DIR}/${DOMAIN}_live_subdomains_${TIMESTAMP}.txt"

