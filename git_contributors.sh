#!/bin/bash

# Set PAGER to cat to ensure direct output
export PAGER=cat

# Check if a glob pattern is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <directory_pattern> <max number of contributors> <since>"
  echo "Example: $0 '/home/user/projects/csm*' 5 '01 January 2024'"
  exit 1
fi

# Store the directory pattern
DIR_PATTERN="$1"
TOP_CONTRIBUTORS="$2"
SINCE="$3"

if [ -z "$TOP_CONTRIBUTORS" ]; then
  TOP_CONTRIBUTORS=5
fi

if [ -n "$SINCE" ]; then
  SINCE="--since \'$3\'"
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


# loop through each directory_pattern for one level only
for dir in $(find $DIR_PATTERN -maxdepth 0 -type d); do 
  process_directory "$dir"
done

# Summarize total contributors
echo "Total Contributors Across All Repositories:"
sort "$TOTAL_CONTRIBUTORS" | awk '{total[$2]+=$1} END {for (name in total) print total[name], name}' | sort -rn | head -$TOP_CONTRIBUTORS

# Clean up temporary file
rm "$TOTAL_CONTRIBUTORS"
