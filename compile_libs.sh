#!/bin/bash

# Create output directories if they don't exist
mkdir -p lib_out/asm
mkdir -p lib_out/stdout
mkdir -p lib_out/stderr
mkdir -p lib_out/parsetree
mkdir -p lib_out/symbol_table

# Clean and build the parser
make clean && clear && make

# Check if the parser was built successfully
if [ ! -f parser ]; then
    echo "Error: parser executable not found. Build failed."
    exit 1
fi

# Initialize the starting index for local addresses
start_index=0

# Compile libraries in a specific order
lib_files=(
    "lib/IO.gs"
    "lib/StringHandler.gs"
    "lib/FileHandler.gs"
    "lib/Utility.gs"
    "lib/Vector.gs"
    "lib/Arithmetic.gs"
    "lib/terminos.gs"
)

for file in "${lib_files[@]}"; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .gs)
        echo "Running parser for $file with start index $start_index..."
        
        # Run the parser with the current start index
        ./parser "$file" "$start_index" > "lib_out/stdout/$filename.out" 2> "lib_out/stderr/$filename.err"
        
        # Update the start_index for the next file from last_index.txt
        if [ -f "last_index.txt" ]; then
            start_index=$(cat last_index.txt)
        fi

        # Move generated files
        if [ -f "code.asm" ]; then
            mv "code.asm" "lib_out/asm/$filename.asm"
        else
            echo "Warning: code.asm not found for $file"
        fi

        if [ -f "parser_output.txt" ]; then
            mv "parser_output.txt" "lib_out/parsetree/$filename.txt"
        else
            echo "Warning: parser_output.txt not found for $file"
        fi

        if [ -f "symbol_table.txt" ]; then
            mv "symbol_table.txt" "lib_out/symbol_table/$filename.txt"
        else
            echo "Warning: symbol_table.txt not found for $file"
        fi
    fi
done

echo "Checking for errors in stderr files..."
grep -ir "Error" lib_out/stderr/*

echo "Checking for warnings in stderr files..."
grep -ir "Warning" lib_out/stderr/*

echo "All library files processed."
echo "The next available local address index is $start_index"
