#!/bin/bash

MATLAB_EXECUTABLE="/usr/local/bin/matlab"

# List of Matlab files 
matlab_files=("d1.m" "d2.m" "d3.m")

# Number of times to run each Matlab file
num_runs=10

# Loop through the Matlab files
for file in "${matlab_files[@]}"
do
    echo "Running Matlab file: $file"
    
    # Inner loop to run each file multiple times
    for ((i=1; i<=$num_runs; i++))
    do
        echo "Run $i of $num_runs"
        $MATLAB_EXECUTABLE -batch "run('$file');"
        # Adjust the Matlab command above as per your requirements
        # You can also use the following line if you have the file path relative to the script location
        # $MATLAB_EXECUTABLE -batch "run('path/to/$file');"
    done
done
