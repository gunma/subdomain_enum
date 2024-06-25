#!/bin/bash

# Function to combine results and remove duplicates
combine_results() {
    cat $1 | sort -u
}

# Get domain input using Zenity
DOMAIN=$(zenity --entry --title="Subdomain Enumeration" --text="Enter the domain:")

# Ensure a domain is provided
if [ -z "$DOMAIN" ]; then
    zenity --error --title="Error" --text="No domain provided. Exiting."
    exit 1
fi

OUTPUT_DIR="subdomain_enum_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/${DOMAIN}_subdomains_${TIMESTAMP}.txt"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Notify the user that enumeration is starting
zenity --info --title="Subdomain Enumeration" --text="Starting subdomain enumeration for: $DOMAIN"

# Run subfinder
zenity --info --title="Running subfinder" --text="Running subfinder..."
subfinder -d $DOMAIN -silent -o ${OUTPUT_DIR}/subfinder_${DOMAIN}.txt

# Run amass
zenity --info --title="Running amass" --text="Running amass..."
amass enum -d $DOMAIN -o ${OUTPUT_DIR}/amass_${DOMAIN}.txt

# Run assetfinder
zenity --info --title="Running assetfinder" --text="Running assetfinder..."
assetfinder --subs-only $DOMAIN > ${OUTPUT_DIR}/assetfinder_${DOMAIN}.txt

# Combine results
zenity --info --title="Combining results" --text="Combining results..."
combine_results "${OUTPUT_DIR}/subfinder_${DOMAIN}.txt ${OUTPUT_DIR}/amass_${DOMAIN}.txt ${OUTPUT_DIR}/assetfinder_${DOMAIN}.txt" > ${OUTPUT_FILE}

# Remove potential duplicates
zenity --info --title="Removing duplicates" --text="Removing duplicates..."
sort -u ${OUTPUT_FILE} -o ${OUTPUT_FILE}

# Run httprobe to check for live subdomains
zenity --info --title="Checking for live subdomains" --text="Checking for live subdomains with httprobe..."
cat ${OUTPUT_FILE} | httprobe > ${OUTPUT_DIR}/${DOMAIN}_live_subdomains_${TIMESTAMP}.txt

# Notify the user that enumeration is complete
zenity --info --title="Subdomain Enumeration Complete" --text="Subdomain enumeration completed.\nResults saved in: ${OUTPUT_FILE}\nLive subdomains saved in: ${OUTPUT_DIR}/${DOMAIN}_live_subdomains_${TIMESTAMP}.txt"

