#!/bin/bash

# Set PAGER to cat to ensure direct output
export PAGER=cat

# Check if a glob pattern is provided
if [ $# -lt 3 ]; then
  echo "Usage: $0 <directory_pattern> <max number of contributors> <since> [--csv]"
  echo "Example: $0 '/home/user/projects/csm*' 5 '01 January 2024' --csv"
  exit 1
fi

# Store the directory pattern
DIR_PATTERN="$1"
TOP_CONTRIBUTORS="$2"
SINCE="$3"
CSV_OUTPUT=false

# Check for the --csv flag
if [ "$4" == "--csv" ]; then
  CSV_OUTPUT=true
fi

if [ -z "$TOP_CONTRIBUTORS" ]; then
  TOP_CONTRIBUTORS=5
fi

if [ -n "$SINCE" ]; then
  SINCE="--since '$SINCE'"
fi

# Temporary file to store total contributors
TOTAL_CONTRIBUTORS=$(mktemp)

# Function to process a git repository
process_directory() {
  local dir="$1"

  echo "Processing directory: $dir"

  # Check if it's a git repository
  if [ -d "$dir/.git" ]; then
    # Run git shortlog and save the output
    echo "Contributors in $dir:"
    cd "$dir"
    git shortlog -sn --all $SINCE | head -$TOP_CONTRIBUTORS

    # Add the contributors to the total file
    git shortlog -sn --all $SINCE >> "$TOTAL_CONTRIBUTORS"

    cd - > /dev/null
    echo "---"
  else
    echo "Not a git repository: $dir"
  fi
}

# Loop through each directory pattern for one level only
for dir in $(find $DIR_PATTERN -maxdepth 0 -type d); do
  process_directory "$dir"
done

# Summarize total contributors
echo "Total Contributors Across All Repositories:"
sort "$TOTAL_CONTRIBUTORS" | awk '{total[$2]+=$1} END {for (name in total) print total[name], name}' | sort -rn | head -$TOP_CONTRIBUTORS

# Export to CSV if the flag is set
if [ "$CSV_OUTPUT" = true ]; then
  CSV_FILE="contributors.csv"
  echo "Total Contributions,Contributor" > "$CSV_FILE"
  sort "$TOTAL_CONTRIBUTORS" | awk '{total[$2]+=$1} END {for (name in total) print total[name], name}' | sort -rn | head -$TOP_CONTRIBUTORS | while read -r line; do
    contributions=$(echo $line | awk '{print $1}')
    contributor=$(echo $line | awk '{for (i=2; i<=NF; i++) printf $i " "; print ""}' | sed 's/ $//')
    echo "$contributions,$contributor" >> "$CSV_FILE"
  done
  echo "Results exported to $CSV_FILE"
fi

# Clean up temporary file
rm "$TOTAL_CONTRIBUTORS"
