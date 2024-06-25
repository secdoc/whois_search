#!/bin/bash

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Please provide an input file containing IP addresses."
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file=$1
output_file="whois_results.txt"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file does not exist."
    exit 1
fi

# Check if whois command is available and get its path
whois_cmd=$(which whois 2>/dev/null)
if [ -z "$whois_cmd" ]; then
    echo "whois command not found in PATH. Checking common locations..."
    for path in "/usr/bin/whois" "/usr/local/bin/whois" "/bin/whois"; do
        if [ -x "$path" ]; then
            whois_cmd="$path"
            break
        fi
    done
    
    if [ -z "$whois_cmd" ]; then
        echo "whois command not found. Please install whois or add it to your PATH."
        exit 1
    fi
fi

echo "Using whois command: $whois_cmd"

# Clear the output file if it already exists
> "$output_file"

# Read IP addresses from input file and perform whois lookup
while IFS= read -r ip || [[ -n "$ip" ]]; do
    # Skip empty lines
    if [ -z "$ip" ]; then
        continue
    fi

    echo "Performing whois lookup for IP: $ip"
    echo "==== WHOIS for $ip ====" >> "$output_file"
    "$whois_cmd" "$ip" >> "$output_file" 2>&1
    echo -e "\n\n" >> "$output_file"
done < "$input_file"

echo "Whois lookups completed. Results saved in $output_file"
